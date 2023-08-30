import Foundation
import Combine

@MainActor
final class HomeViewModel : ObservableObject {
    
    @Published var transactions : [Transaction]? = nil
    @Published var filteredTransactions : [Transaction] = []
    @Published var currencyRates : Rates? = nil
    @Published var showAllTransactions = false
    var isLoading : Bool = false
    @Published var searchtext : String = ""
    @Published var searchScope : String = "All"
    @Published var allSearchScopes : [String] = []
    private var cancellable = Set<AnyCancellable>()
    var isSearching : Bool = false
    
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
    
    private func filterTransactions (searchText: String, currentSearchScope: String) {
        guard let transactions else {return}
        var transactionsInScope = transactions
        switch currentSearchScope {
        case "All":
            break
        default:
            transactionsInScope = transactions.filter({ trans in
                guard let category = trans.category else {return false}
                return category.name.lowercased() == currentSearchScope.lowercased()
            })
        }
        
        let search = searchText.lowercased()
        filteredTransactions = transactionsInScope.filter({ transaction in
            guard !searchText.isEmpty, let category = transaction.category?.name else { return true }
            let categoryContainsSearch = category.lowercased().contains(search)
            let subCategoryContainsSearch = transaction.subcategory.lowercased().contains(search)
            return categoryContainsSearch || subCategoryContainsSearch
        })
    }
    
    func loadMore () async -> Void {
        isLoading = true
        // wait code
        isLoading = false
    }
// GET Request from Firebase DB
    func getLastTransactions() {
        Task {
            let FBTransactions = try await TransactionManager.shared.getLastNTransactions(limit: 20)
            let fetchedTransactions = FBTransactions.map { trans in Transaction(DBTransaction: trans)}
            self.transactions = fetchedTransactions
            self.allSearchScopes = ["All"] + Set (fetchedTransactions.compactMap { $0.category?.name })
            print("new transactions loaded!")
        }
    }
    
    func fetchCurrencyRates () -> Void {
        Task {
            let fetchedData = await APIService.shared.fetchCurrencyRates()
            self.currencyRates = fetchedData
        }
    }
    
}

