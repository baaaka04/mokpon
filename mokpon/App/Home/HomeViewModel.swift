import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class HomeViewModel : ObservableObject {
    
    @Published var transactions : [Transaction]? = nil
    @Published var filteredTransactions : [Transaction] = []
    @Published var currencyRates : Rates? = nil
    @Published var showAllTransactions = false
    @Published var searchtext : String = ""
    @Published var searchScope : String = "All"
    @Published var allSearchScopes : [String] = []
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
            if var trans = self.transactions {
                // append for pagination
                trans.append(contentsOf: newTransactions.map { Transaction(DBTransaction: $0) })
                self.allSearchScopes = ["All"] + Set (trans.compactMap { $0.category?.name })
                self.transactions = trans
            } else {
                self.transactions = newTransactions.map{ Transaction(DBTransaction: $0)}
            }
            if let lastDocument {
                self.lastDocument = lastDocument
            }
            print("\(Date()): new transactions has been loaded!")
        }
    }
    
    func deleteTransaction(transactionId: String) {
        Task {
            try await TransactionManager.shared.deleteTransaction(transactionId: transactionId)
        }
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
    
    func fetchCurrencyRates () -> Void {
        Task {
            let fetchedData = await APIService.shared.fetchCurrencyRates()
            self.currencyRates = fetchedData
        }
    }
    
}

