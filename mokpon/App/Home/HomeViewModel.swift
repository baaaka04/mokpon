import Foundation
import Combine

final class HomeViewModel : ObservableObject {
    
    @Published var transactions : [Transaction] = []
    @Published var filteredTransactions : [Transaction] = []
    @Published var currencies = Rates(KGS: 85.1, RUB: 75.1)
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
        
        var transactionsInScope = transactions
        switch currentSearchScope {
        case "All":
            break
        default:
            transactionsInScope = transactions.filter({ $0.category.lowercased() == currentSearchScope.lowercased()
            })
        }
        
        let search = searchText.lowercased()
        filteredTransactions = transactionsInScope.filter({ transaction in
            guard !searchText.isEmpty else { return true }
            let categoryContainsSearch = transaction.category.lowercased().contains(search)
            let subCategoryContainsSearch = transaction.subCategory.lowercased().contains(search)
            return categoryContainsSearch || subCategoryContainsSearch
        })
    }
    
    func loadMore () async -> Void {
        isLoading = true
        // wait code
        isLoading = false
    }
//     GET Request /transactions route
    func fetchTransactions () async -> Void {
        let fetchedData = await APIService.shared.fetchTransactions()
        await MainActor.run {
            self.transactions = fetchedData
            allSearchScopes = ["All"] + Set(fetchedData.map({ $0.category })).map({ $0 })
        }
        self.isLoading = false
    }
    
//    POST Request /newRow route
    func sendNewTransaction (trans: Transaction) async -> Void {
        let fetchedData = await APIService.shared.sendNewTransaction(trans: trans)
        await MainActor.run {
            self.transactions = fetchedData
        }
    }
    
    func fetchCurrency () async -> Void {
        let fetchedData = await APIService.shared.fetchCurrency()
        await MainActor.run {
            self.currencies = fetchedData
        }
    }
    
}
