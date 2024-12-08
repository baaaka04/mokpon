import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var transactions: [Transaction] = []
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
                let (newTransactions, lastDocument) = await transactionManager.getLastNTransactions(
                    limit: 20,
                    lastDocument: self.lastDocument,
                    searchText: searchtext.lowercased(),
                    selectedCategoryId: selectedScope?.id
                )
                self.lastDocument = lastDocument
                // append for pagination
                self.transactions.append(contentsOf: newTransactions.compactMap {
                    if let category = directoriesManager.getCategory(byID: $0.categoryId),
                       let currency = directoriesManager.getCurrency(byID: $0.currencyId) {
                        return Transaction(DBTransaction: $0, category: category , currency: currency)
                    } else { return nil } // if couldn't find a category/currency, then skip
                })
                let newScopes = [] + Set(searchScopes + self.transactions.map{ $0.category })
                self.searchScopes = newScopes.sorted(by: { $0.name < $1.name })
                print("\(Date()): HomeViewModel - New transactions have been loaded!")
                self.isLoading = false
            }
        }
    }

    func updateTransactions() {
        self.transactions = []
        self.lastDocument = nil
        getTransactions()
    }

    func deleteTransaction(transaction: Transaction) {
        Task {
            do {
                try await transactionManager.deleteTransaction(transactionId: transaction.id)
                self.transactions.remove(object: transaction)
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
        try await amountManager.updateUserAmounts(userId: user.uid, curId:curId, sumDiff: sumDiff)
    }
    
    func fetchCurrencyRates() -> Void {
        Task {
            let fetchedData = await currencyRatesService.fetchCurrencyRates()
            self.currencyRates = fetchedData
        }
    }
    
}

