import Foundation


class HomeViewModel : ObservableObject {
    
    @Published var transactions = [Transaction]()
    @Published var currencies = Rates(KGS: 85.1, RUB: 75.1)
    @Published var showAllTransactions = false
    var isLoading : Bool = false

    
    func loadMore () async -> Void {
        isLoading = true
        // wait code
        isLoading = false
    }
//     GET Request /transactions route
    func fetchTransactions () async -> Void {
        await self.transactions = APIService.shared.fetchTransactions()
        self.isLoading = false
    }
    
//    POST Request /newRow route
    func sendNewTransaction (trans: Transaction) async -> Void {
        self.transactions = await APIService.shared.sendNewTransaction(trans: trans)
    }
    
    func fetchCurrency () async -> Void {
        self.currencies = await APIService.shared.fetchCurrency()
    }
    
}
