import Foundation

@MainActor
final class CategoryViewModel : ObservableObject {
    
    @Published var pieChartData : [ChartData] = []
    private(set) var currencyRatesService: CurrencyManager
    private(set) var chartsManager: ChartsManager
    private(set) var directoriesManager: DirectoriesManager
        
    init (appContext: AppContext) {
        self.currencyRatesService = appContext.currencyRatesService
        self.chartsManager = appContext.chartsManager
        self.directoriesManager = appContext.directoriesManager
        print("\(Date()): INIT CategoryViewModel")
    }
    deinit {print("\(Date()): DEINIT CategoryViewModel")}
    
    func getCategoryExpenses (currencyName: String, date: ChartsDate, category: Category) {
        Task {
            guard let currency = directoriesManager.getCurrency(byName: currencyName) else {return}
            let fetchedData = try await chartsManager.getTransactions(year: date.year, month: date.month, categoryId: category.id)
            let groupedByCategory = Dictionary(grouping: fetchedData) { $0.subcategory }
            let categoryData = groupedByCategory.map { (key: String, value: [DBTransaction]) in
                let converted = value.compactMap { (trans : DBTransaction) -> DBTransaction? in
                    var newDBTrans : DBTransaction = trans
                    guard let oldCurrency = directoriesManager.getCurrency(byID: trans.currencyId) else {return nil}
                    newDBTrans.sum = currencyRatesService.convertCurrency(value: trans.sum, from: oldCurrency.name, to: currencyName) ?? 0
                    return newDBTrans
                }
                let categorySum = converted.reduce(0) { $0 + $1.sum }
                
                return ChartData(
                    category:
                        Category(id: UUID().description, name: key, icon: category.icon, type: category.type),
                    currency: currency,
                    sum: -categorySum,
                    month: date.month,
                    year: date.year
                )
            }
            self.pieChartData = categoryData.sorted {$0.sum > $1.sum}
        }
    }
    
}
