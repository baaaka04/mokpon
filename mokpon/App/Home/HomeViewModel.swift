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
    private(set) var authManager: AuthenticationManager
    private(set) var directoriesManager: DirectoriesManager
            
    init(appContext: AppContext) {
        self.currencyRatesService = appContext.currencyRatesService
        self.transactionManager = appContext.transactionManager
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
        // Update local transactions and amounts
        if !self.transactions.isEmpty {
            self.transactions.insert(transaction, at: 0)
        } else {
            self.transactions = [transaction]
        }
        try localAmountUpdate(curId: transaction.currency.id, sumDiff: transaction.sum)

        let user = try authManager.getAuthenticatedUser()
        let deviceTransactionId = transaction.id
        do {
            // Use atomic operation to create transaction and update amounts together
            let newTransactionId = try await transactionManager.createTransactionWithAmountUpdate(transaction: transaction, userId: user.uid)
            if let index = self.transactions.firstIndex(where: { $0.id == deviceTransactionId }) {
                self.transactions[index].id = newTransactionId
            }
            print("\(Date()): Transaction has been sent")
        } catch {
            // Rollback both UI changes on failure
            if let index = self.transactions.firstIndex(where: { $0.id == deviceTransactionId }) {
                self.transactions.remove(at: index)
            }
            try? localAmountUpdate(curId: transaction.currency.id, sumDiff: -transaction.sum)
            print(error)
            throw error
        }
    }

    func updateTransactions() {
        self.transactions = []
        self.lastDocument = nil
        self.hotkeys = nil
        getTransactions()
        getHotkeys()
    }

    func deleteTransaction(transaction: Transaction) async throws {
        // Update locally
        self.transactions.remove(object: transaction)
        try localAmountUpdate(curId: transaction.currency.id, sumDiff: -transaction.sum)
        do {
            // Update backend
            let userId = try authManager.getAuthenticatedUser().uid
            try await transactionManager.deleteTransactionWithAmountUpdate(transaction: transaction, userId: userId)
            if self.transactions.count < 5 { // 5 is the limit for HomeView
                getTransactions()
            }
        } catch {
            // Restore transactions and amounts
            self.transactions.insert(transaction, at: 0)
            try? localAmountUpdate(curId: transaction.currency.id, sumDiff: transaction.sum)
            print(error)
            throw error
        }
    }

    func getUserAmounts() {
        Task {
            let user = try authManager.getAuthenticatedUser()
            do {
                self.amounts = try await transactionManager.getUserAmounts(userId: user.uid)
            } catch {
                print("\(Date()): HomeViewModel - Error while getting user amounts: \(error)")
            }
            print("\(Date()): HomeViewModel - Amounts have been updated!")
        }
    }

    private func localAmountUpdate(curId: String, sumDiff: Int) throws {
        guard let current = self.amounts else { throw AppError.noDataToPresent }
        self.amounts = current.map { amount in
            if amount.curId == curId {
                return Amount(curId: amount.curId, sum: amount.sum + sumDiff)
            }
            return amount
        }
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

