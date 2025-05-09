import Foundation


final class AppContext {
    
    let currencyRatesService = CurrencyManager()
    let transactionManager = TransactionManager()
    let amountManager = AmountManager()
    let authManager = AuthenticationManager()
    let directoriesManager = DirectoriesManager()
    let userManager = UserManager()
    let chartsManager = ChartsManager()
    
    init() {print("\(Date()): INIT AppContext")}
    deinit {print("\(Date()): DEINIT AppContext")}
}
