import Foundation

@MainActor
final class ChartsViewModel : ObservableObject {
    
    @Published var selectedChart : ChartType = .bar
    @Published var compareData : Comparation = .monthly
    
    @Published var pieChartData : [ChartData] = []
    @Published var barChartData : [ChartData] = []
    
    var chartDate : ChartsDate = ChartsDate(
        month: Calendar.current.component(.month, from: Date()),
        year: Calendar.current.component(.year, from: Date())
    )
        
    private func convertTransactionsCurrency (transactions: [DBTransaction], newCurrency: Currency) -> [DBTransaction] {
        let transInMainCurrency = transactions.compactMap { trs -> DBTransaction? in
            var newTrs = trs
            guard let oldCurrency = DirectoriesManager.shared.getCurrency(byID: trs.currencyId) else {return nil}
            newTrs.sum = TransactionManager.shared.convertCurrency(value: trs.sum, from: oldCurrency.name, to: newCurrency.name) ?? 0
            newTrs.currencyId = newCurrency.id
            return newTrs
        }
        return transInMainCurrency
    }
    
    private func getMonthData (mainCurrency: String, year: Int, month: Int) async throws -> [ChartData] {
        guard let newCurrency = DirectoriesManager.shared.getCurrency(byName: mainCurrency) else {return []}
        let transactions : [DBTransaction] = try await ChartsManager.shared.getTransactions(year: year, month: month)
        //convert expenses in main currency
        let transInMainCurrency = convertTransactionsCurrency(transactions: transactions, newCurrency: newCurrency)
        //groupBy category
        let transGroupedByCategory = Dictionary(grouping: transInMainCurrency) { $0.categoryId }
        
        let chartsData = transGroupedByCategory.compactMap {
            (categoryId: String, transactionsForCategory: [DBTransaction]) -> ChartData? in
            
            guard let category = DirectoriesManager.shared.getCategory(byID: categoryId) else { return nil }
            let sum = transactionsForCategory.reduce(0) { $0 - $1.sum }
            
            return ChartData(category: category, currency: newCurrency, sum: sum, month: month, year: year)
        }
        return chartsData
            .filter{ dataRow in dataRow.category.type != .income && dataRow.category.type != .exchange }
            .sorted { $0.sum > $1.sum }
    }
    
    func getPieChartData (mainCurrency: String) {
        Task {
            self.pieChartData = try await getMonthData(mainCurrency: mainCurrency, year: chartDate.year, month: chartDate.month)
        }
    }
    
    func getBarChartData (mainCurrency: String) {
        Task {
            let currentMonthData = try await getMonthData(mainCurrency: mainCurrency, year: chartDate.year, month: chartDate.month)
            
            switch compareData {
            case .monthly:
                let previousMonthData = try await getMonthData(mainCurrency: mainCurrency, year: chartDate.year, month: chartDate.prevMonth)
                self.barChartData = previousMonthData + currentMonthData
            case .yearly:
                let previousYearData = try await getMonthData(mainCurrency: mainCurrency, year: chartDate.prevYear, month: chartDate.month)
                self.barChartData = previousYearData + currentMonthData
            }
        }
    }
        
}


