import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var transactions: [Transaction]?
    @Published var filteredTransactions: [Transaction] = []
    @Published var currencyRates: Rates? = nil
    @Published var showAllTransactions = false
    @Published var amounts: [Amount]? = nil

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
        Task {
            if !self.isLoading {
                self.isLoading = true
                let (DBTransactions, lastDocument) = await transactionManager.getLastNTransactions(
                    limit: 20,
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
                if var transactions {
                    // append for pagination
                    self.transactions?.append(contentsOf: newTransactions)
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
        guard var transactions, !transactions.isEmpty else { return }
        let deviceTransactionId = transaction.id
        self.transactions?.insert(transaction, at: 0)
        let user = try authManager.getAuthenticatedUser()
        do {
            let newTransactionId = try await transactionManager.createNewTransaction(transaction: transaction, userId: user.uid)
            if let index = self.transactions?.firstIndex(where: { $0.id == deviceTransactionId }) {
                self.transactions?[index].id = newTransactionId
            }
            try await self.updateUserAmounts(
                sum: transaction.sum,
                currencyId: transaction.currency.id,
                type: transaction.type
            )
            print("\(Date()): Transaction has been sent")
        } catch {
            if let index = self.transactions?.firstIndex(where: { $0.id == deviceTransactionId }) {
                self.transactions?.remove(at: index)
            }
            print(error)
        }
    }

    func updateUserAmounts(sum: Int, currencyId: String, type: ExpensesType) async throws {
        let user = try authManager.getAuthenticatedUser()
        self.amounts = try await amountManager.updateUserAmounts(userId: user.uid, curId: currencyId, sumDiff: sum)
    }

    func updateTransactions() {
        self.transactions = nil
        self.lastDocument = nil
        getTransactions()
    }

    func deleteTransaction(transaction: Transaction) {
        Task {
            do {
                try await transactionManager.deleteTransaction(transactionId: transaction.id)
                self.transactions?.remove(object: transaction)
            } catch {
                print(error)
            }
        }
    }

    func getUserAmounts() {
        Task {
            let user = try authManager.getAuthenticatedUser()
            self.amounts = try await amountManager.getUserAmounts(userId: user.uid)
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
    
}

