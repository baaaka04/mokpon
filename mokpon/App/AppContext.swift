import Foundation


final class AppContext {
    
    let currencyRatesService = CurrencyManager()
    let transactionManager = TransactionManager()
    let authManager = AuthenticationManager()
    let userManager = UserManager()
    let chartsManager = ChartsManager()
    
    init() {print("\(Date()): INIT AppContext")}
    deinit {print("\(Date()): DEINIT AppContext")}
}
