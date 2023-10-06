import Foundation


final class AppContext {
    
    let currencyRatesService = CurrencyManager(completion: {})
    let transactionManager = TransactionManager()
    let amountManager = AmountManager()
    let authManager = AuthenticationManager()
    let directoriesManager = DirectoriesManager(completion: {})
    let userManager = UserManager()
    let authentificationManage = AuthenticationManager()
    let chartsManager = ChartsManager()
    
    init() {print("\(Date()): INIT AppContext")}
    deinit {print("\(Date()): DEINIT AppContext")}
}
