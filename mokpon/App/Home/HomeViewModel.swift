import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class HomeViewModel: ObservableObject, TransactionSendable {

    @Published var transactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    @Published var currencyRates: Rates? = nil
    @Published var showAllTransactions = false
    @Published var amounts: [Amount]? = nil
    @Published var hotkeys: [Hotkey]? = nil

    //Search bar
    @Published var searchtext: String = ""
    @Published var selectedScope: Category?
    var searchScopes: [Category] = []

    //Pagination
    private var cancellable = Set<AnyCancellable>()
    var isLoading: Bool = false
    private var lastDocument: DocumentSnapshot? = nil

    //Managers
    private(set) var currencyRatesService: CurrencyManager
    private(set) var transactionManager: TransactionManager
    private(set) var amountManager: AmountManager
    private(set) var authManager: AuthenticationManager
    private(set) var directoriesManager: DirectoriesManager
            
    init(appContext: AppContext) {
        self.currencyRatesService = appContext.currencyRatesService
        self.transactionManager = appContext.transactionManager
        self.amountManager = appContext.amountManager
        self.authManager = appContext.authManager
        self.directoriesManager = appContext.directoriesManager
        addSubscribers()
        print("\(Date()): INIT HomeViewModel")
    }
    deinit {print("\(Date()): DEINIT HomeViewModel")}
        
    private func addSubscribers() {
        $searchtext
            .debounce(for: 1.0, scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateTransactions()
            }
            .store(in: &cancellable)
    }

    // GET Request from Firebase DB
    func getTransactions() {
        if !self.isLoading {
            self.isLoading = true
            Task {
                let user = try authManager.getAuthenticatedUser()
                let (DBTransactions, lastDocument) = await transactionManager.getLastNTransactions(
                    limit: 20,
                    userId: user.uid,
                    lastDocument: self.lastDocument,
                    searchText: searchtext.lowercased(),
                    selectedCategoryId: selectedScope?.id
                )
                self.lastDocument = lastDocument
                let newTransactions = DBTransactions.compactMap {
                    if let category = directoriesManager.getCategory(byID: $0.categoryId),
                       let currency = directoriesManager.getCurrency(byID: $0.currencyId) {
                        return Transaction(DBTransaction: $0, category: category , currency: currency)
                    } else { return nil } // if couldn't find a category/currency, then skip
                }
                if !self.transactions.isEmpty {
                    // append for pagination
                    self.transactions.append(contentsOf: newTransactions)
                } else {
                    self.transactions = newTransactions
                }
                if let categories = directoriesManager.categories {
                    self.searchScopes = categories.sorted(by: { $0.name < $1.name })
                }
                print("\(Date()): HomeViewModel - New transactions have been loaded!")
                self.isLoading = false
            }
        }
    }

    func sendNewTransaction(transaction: Transaction) async throws {
        let deviceTransactionId = transaction.id
        if !self.transactions.isEmpty {
            self.transactions.insert(transaction, at: 0)
        } else {
            self.transactions = [transaction]
        }
        let user = try authManager.getAuthenticatedUser()
        do {
            let newTransactionId = try await transactionManager.createNewTransaction(transaction: transaction, userId: user.uid)
            if let index = self.transactions.firstIndex(where: { $0.id == deviceTransactionId }) {
                self.transactions[index].id = newTransactionId
            }
            try await self.updateUserAmounts(
                sum: transaction.sum,
                currencyId: transaction.currency.id,
                type: transaction.type
            )
            print("\(Date()): Transaction has been sent")
        } catch {
            if let index = self.transactions.firstIndex(where: { $0.id == deviceTransactionId }) {
                self.transactions.remove(at: index)
            }
            print(error)
        }
    }

    func updateUserAmounts(sum: Int, currencyId: String, type: ExpensesType) async throws {
        let user = try authManager.getAuthenticatedUser()
        self.amounts = try await amountManager.updateUserAmounts(userId: user.uid, curId: currencyId, sumDiff: sum)
    }

    func updateTransactions() {
        self.transactions = []
        self.lastDocument = nil
        self.hotkeys = nil
        getTransactions()
        getHotkeys()
    }

    func deleteTransaction(transaction: Transaction) {
        Task {
            do {
                try await transactionManager.deleteTransaction(transactionId: transaction.id)
                self.transactions.remove(object: transaction)
                if self.transactions.count < 5 { // 5 is the limit for HomeView
                    await MainActor.run { getTransactions() }
                }
            } catch {
                print(error)
            }
        }
    }

    func getUserAmounts() {
        Task {
            let user = try authManager.getAuthenticatedUser()
            do {
                self.amounts = try await amountManager.getUserAmounts(userId: user.uid)
            } catch {
                guard let currencies: [Currency] = directoriesManager.currencies else { return }
                try await amountManager.createAmounts(userId: user.uid, currencies: currencies)
                self.amounts = try await amountManager.getUserAmounts(userId: user.uid)
            }
            print("\(Date()): HomeViewModel - Amounts have been updated!")
        }
    }
    
    func updateUserAmount(curId: String, sumDiff: Int) async throws {
        let user = try authManager.getAuthenticatedUser()
        self.amounts = try await amountManager.updateUserAmounts(userId: user.uid, curId:curId, sumDiff: sumDiff)
    }
    
    func fetchCurrencyRates() -> Void {
        Task {
            let fetchedData = await currencyRatesService.fetchCurrencyRates()
            self.currencyRates = fetchedData
        }
    }

    func getHotkeys() -> Void {
        Task {
            do {
                if self.hotkeys != nil { throw AppError.noNeedToExecute }

                let user = try authManager.getAuthenticatedUser()
                let (FBTransactions, _) = await transactionManager.getLastNTransactions(limit: 300, userId: user.uid)
                let DBHotkeys = Dictionary(grouping: FBTransactions, by: {DBHotkey(categoryId: $0.categoryId, subcategory: $0.subcategory, count: 0)})
                    .map { (key, arr) in DBHotkey(categoryId: key.categoryId, subcategory: key.subcategory, count: arr.count) }
                    .sorted { $0.count > $1.count }

                self.hotkeys = DBHotkeys
                    .prefix(16)
                    .compactMap {
                        if let category = directoriesManager.getCategory(byID: $0.categoryId) {
                            return Hotkey(category: category, subcategory: $0.subcategory)
                        } else { return nil } //if couldn't find a category, then skip
                    }
            } catch {
                print(error)
            }
        }

    }

}

