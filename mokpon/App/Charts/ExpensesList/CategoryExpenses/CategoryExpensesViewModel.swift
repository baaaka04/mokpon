import Foundation

@MainActor
final class CategoryViewModel: ObservableObject {
    
    @Published var pieChartData: [ChartData] = []
    private(set) var currencyRatesService: CurrencyManager
    private(set) var chartsManager: ChartsManager
    private(set) var authManager: AuthenticationManager
    private var isLoading: Bool = false

    init(appContext: AppContext) {
        self.currencyRatesService = appContext.currencyRatesService
        self.chartsManager = appContext.chartsManager
        self.authManager = appContext.authManager
        print("\(Date()): INIT CategoryViewModel")
    }
    deinit {print("\(Date()): DEINIT CategoryViewModel")}
    
    func getCategoryExpenses(currency: Currency, date: ChartsDate, category: CategoryEnum) {
        guard !self.isLoading else { return }
        self.isLoading = true
        Task {
            let user = try authManager.getAuthenticatedUser()
            let fetchedData = try await chartsManager.getTransactions(userId: user.uid, year: date.currentPeriod.year, month: date.currentPeriod.month, categoryId: category.id)
            let groupedByCategory = Dictionary(grouping: fetchedData) { $0.subcategory }
            let categoryData = groupedByCategory.map { (key: String, value: [DBTransaction]) in
                let converted = value.compactMap { (trans: DBTransaction) -> DBTransaction? in
                    var newDBTrans: DBTransaction = trans
                    newDBTrans.sum = currencyRatesService.convertCurrency(value: trans.sum, from: trans.currencyId.name, to: currency.name) ?? 0
                    return newDBTrans
                }
                let categorySum = converted.reduce(0) { $0 + $1.sum }
                
                return ChartData(
                    category: category,
                    currency: currency,
                    subcategory: key,
                    sum: -categorySum,
                    month: date.currentPeriod.month,
                    year: date.currentPeriod.year
                )
            }
            self.pieChartData = categoryData.sorted {$0.sum > $1.sum}
            self.isLoading = false
        }
    }
    
}
