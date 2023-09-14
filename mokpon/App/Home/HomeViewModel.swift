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
    
    init() {
        addSubscribers()
    }
    
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
            let (newTransactions, lastDocument) = try await TransactionManager.shared.getLastNTransactions(limit: 10, lastDocument: self.lastDocument)
            if let lastDocument {
                self.lastDocument = lastDocument
            }
            // append for pagination
            self.transactions.append(contentsOf: newTransactions.compactMap {
                if let category = DirectoriesManager.shared.getCategory(byID: $0.categoryId),
                   let currency = DirectoriesManager.shared.getCurrency(byID: $0.currencyId) {
                    return Transaction(DBTransaction: $0, category: category , currency: currency)
                } else { return nil } // if couldn't find a category/currency, then skip
            })
            self.allSearchScopes = ["All"] + Set (self.transactions.map { $0.category.name })
            print("\(Date()): New transactions have been loaded!")
        }
    }
    
    func getLastTransactions () {
        Task {
            // Delay (1 second = 1_000_000_000 nanoseconds)
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            let (newTransactions, lastDocument) = try await TransactionManager.shared.getLastNTransactions(limit: 10)
            self.transactions = newTransactions.compactMap {
                if let category = DirectoriesManager.shared.getCategory(byID: $0.categoryId),
                   let currency = DirectoriesManager.shared.getCurrency(byID: $0.currencyId) {
                    return Transaction(DBTransaction: $0, category: category , currency: currency)
                } else { return nil } // if couldn't find a category/currency, then skip
            }
            self.allSearchScopes = ["All"] + Set (self.transactions.map { $0.category.name })
            self.lastDocument = lastDocument
            print("\(Date()): Last transactions have been loaded!")
        }
    }
    
    func deleteTransaction(transactionId: String) {
        Task {
            try await TransactionManager.shared.deleteTransaction(transactionId: transactionId)
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
            // Delay (1 second = 1_000_000_000 nanoseconds)
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            let user = try AuthenticationManager.shared.getAuthenticatedUser()
            self.amounts = try await AmountManager.shared.getUserAmounts(userId: user.uid)
            print("\(Date()): Amounts have been updated!")
        }
    }
    
    func updateUserAmount(curId: String, sumDiff: Int) async throws {
        let user = try AuthenticationManager.shared.getAuthenticatedUser()
        try await AmountManager.shared.updateUserAmounts(userId: user.uid, curId:curId, sumDiff: sumDiff)
    }
    
    func fetchCurrencyRates () -> Void {
        Task {
            let fetchedData = await APIService.shared.fetchCurrencyRates()
            self.currencyRates = fetchedData
        }
    }
    
}

