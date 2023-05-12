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
        let fetchedData = await APIService.shared.fetchTransactions()
        await MainActor.run {
            self.transactions = fetchedData
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
