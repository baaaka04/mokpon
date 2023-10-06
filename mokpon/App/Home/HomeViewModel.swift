import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class HomeViewModel : ObservableObject {
    
    @Published var transactions : [Transaction] = []
    @Published var filteredTransactions : [Transaction] = []
    @Published var currencyRates : Rates? = nil
    @Published var showAllTransactions = false
    @Published var searchtext : String = ""
    @Published var searchScope : String = "All"
    @Published var allSearchScopes : [String] = []
    @Published var amounts : [Amount]? = nil
    private var cancellable = Set<AnyCancellable>()
    var isSearching : Bool = false
    private var lastDocument : DocumentSnapshot? = nil
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
    
    func setupSearching (isSearching : Bool) {
        self.isSearching = isSearching
    }
    
    private func addSubscribers () {
        $searchtext
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] (searchText, searchScope) in
                self?.filterTransactions(searchText: searchText, currentSearchScope: searchScope)
            }
            .store(in: &cancellable)
    }
    
    // GET Request from Firebase DB
    func getTransactions () {
        Task {
            let (newTransactions, lastDocument) = try await transactionManager.getLastNTransactions(limit: 10, lastDocument: self.lastDocument)
            if let lastDocument {
                self.lastDocument = lastDocument
            }
            // append for pagination
            self.transactions.append(contentsOf: newTransactions.compactMap {
                if let category = directoriesManager.getCategory(byID: $0.categoryId),
                   let currency = directoriesManager.getCurrency(byID: $0.currencyId) {
                    return Transaction(DBTransaction: $0, category: category , currency: currency)
                } else { return nil } // if couldn't find a category/currency, then skip
            })
            self.allSearchScopes = ["All"] + Set (self.transactions.map { $0.category.name })
            print("\(Date()): HomeViewModel - New transactions have been loaded!")
        }
    }
    
    func getLastTransactions () {
        Task {
            let (newTransactions, lastDocument) = try await transactionManager.getLastNTransactions(limit: 10)
            self.transactions = newTransactions.compactMap {
                if let category = directoriesManager.getCategory(byID: $0.categoryId),
                   let currency = directoriesManager.getCurrency(byID: $0.currencyId) {
                    return Transaction(DBTransaction: $0, category: category , currency: currency)
                } else { return nil } // if couldn't find a category/currency, then skip
            }
            self.allSearchScopes = ["All"] + Set (self.transactions.map { $0.category.name })
            self.lastDocument = lastDocument
            print("\(Date()): HomeViewModel - Last transactions have been loaded!")
        }
    }
    
    func deleteTransaction(transactionId: String) {
        Task {
            try await transactionManager.deleteTransaction(transactionId: transactionId)
        }
    }
    
    private func filterTransactions (searchText: String, currentSearchScope: String) {
        var transactionsInScope = transactions
        switch currentSearchScope {
        case "All":
            break
        default:
            transactionsInScope = transactions.filter({ trans in
                trans.category.name.lowercased() == currentSearchScope.lowercased()
            })
        }
        
        let search = searchText.lowercased()
        filteredTransactions = transactionsInScope.filter({ transaction in
            guard !searchText.isEmpty else { return true }
            let categoryContainsSearch = transaction.category.name.lowercased().contains(search)
            let subCategoryContainsSearch = transaction.subcategory.lowercased().contains(search)
            return categoryContainsSearch || subCategoryContainsSearch
        })
    }
        
    func getUserAmounts () {
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
    
    func fetchCurrencyRates () -> Void {
        Task {
            let fetchedData = await currencyRatesService.fetchCurrencyRates()
            self.currencyRates = fetchedData
        }
    }
    
}

