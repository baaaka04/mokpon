import Foundation

@MainActor
final class CategoryViewModel : ObservableObject {
    
    @Published var pieChartData : [ChartData] = []
    
    func getCategoryExpenses (category: Category, currencyName: String, date: ChartsDate) {
        Task {
            guard let currency = DirectoriesManager.shared.getCurrency(byName: currencyName) else {return}
            let fetchedData = try await ChartsManager.shared.getTransactions(year: date.year, month: date.month, categoryId: category.id)
            let groupedByCategory = Dictionary(grouping: fetchedData) { $0.subcategory }
            let categoryData = groupedByCategory.map { (key: String, value: [DBTransaction]) in
                let converted = value.compactMap { (trans : DBTransaction) -> DBTransaction? in
                    var newDBTrans : DBTransaction = trans
                    guard let oldCurrency = DirectoriesManager.shared.getCurrency(byID: trans.currencyId) else {return nil}
                    newDBTrans.sum = TransactionManager.shared.convertCurrency(value: trans.sum, from: oldCurrency.name, to: currencyName) ?? 0
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
