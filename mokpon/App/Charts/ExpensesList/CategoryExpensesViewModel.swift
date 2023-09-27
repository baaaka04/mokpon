import Foundation

@MainActor
final class CategoryViewModel : ObservableObject {
    
    @Published var pieChartData : [ChartData] = []
    let currencyRatesService: CurrencyManager
    let chartsManager: ChartsManager
    let directoriesManager: DirectoriesManager
    
    init (currencyRatesService: CurrencyManager, chartsManager: ChartsManager, directoriesManager: DirectoriesManager) {
        self.currencyRatesService = currencyRatesService
        self.chartsManager = chartsManager
        self.directoriesManager = directoriesManager
    }
    
    func getCategoryExpenses (category: Category, currencyName: String, date: ChartsDate) {
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
