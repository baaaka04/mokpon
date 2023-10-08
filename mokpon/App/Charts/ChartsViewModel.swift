import Foundation

@MainActor
final class ChartsViewModel : ObservableObject {
    
    @Published var selectedChart : ChartType = .bar
    @Published var compareData : Comparation = .monthly
    
    @Published var pieChartData : [ChartData] = []
    @Published var barChartData : [ChartData] = []
    
    let categoryViewModel : CategoryViewModel
    
    let currencyRatesService: CurrencyManager
    let chartsManager: ChartsManager
    let directoriesManager: DirectoriesManager
    
    var chartDate : ChartsDate = ChartsDate(
        month: Calendar.current.component(.month, from: Date()),
        year: Calendar.current.component(.year, from: Date())
    )
    
    init (appContext: AppContext) {
        self.currencyRatesService = appContext.currencyRatesService
        self.chartsManager = appContext.chartsManager
        self.directoriesManager = appContext.directoriesManager
        self.categoryViewModel = CategoryViewModel(appContext: appContext)
        print("\(Date()): INIT ChartsViewModel")
    }
    deinit {print("\(Date()): DEINIT ChartsViewModel")}
        
    private func convertTransactionsCurrency (transactions: [DBTransaction], newCurrency: Currency) -> [DBTransaction] {
        let transInMainCurrency = transactions.compactMap { trs -> DBTransaction? in
            var newTrs = trs
            guard let oldCurrency = directoriesManager.getCurrency(byID: trs.currencyId) else {return nil}
            newTrs.sum = currencyRatesService.convertCurrency(value: trs.sum, from: oldCurrency.name, to: newCurrency.name) ?? 0
            newTrs.currencyId = newCurrency.id
            return newTrs
        }
        return transInMainCurrency
    }
    
    private func getMonthData (mainCurrency: String, year: Int, month: Int) async throws -> [ChartData] {
        guard let newCurrency = directoriesManager.getCurrency(byName: mainCurrency) else {return []}
        let transactions : [DBTransaction] = try await chartsManager.getTransactions(year: year, month: month)
        //convert expenses into main currency
        let transInMainCurrency = convertTransactionsCurrency(transactions: transactions, newCurrency: newCurrency)
        //groupBy category
        let transGroupedByCategory = Dictionary(grouping: transInMainCurrency) { $0.categoryId }
        
        let chartsData = transGroupedByCategory.compactMap {
            (categoryId: String, transactionsForCategory: [DBTransaction]) -> ChartData? in
            
            guard let category = directoriesManager.getCategory(byID: categoryId) else { return nil }
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
            var barChartData : [ChartData] = []
            let currentMonthData = try await getMonthData(mainCurrency: mainCurrency, year: chartDate.year, month: chartDate.month)
            
            switch compareData {
            case .monthly:
                let previousMonthData = try await getMonthData(mainCurrency: mainCurrency, year: chartDate.year, month: chartDate.prevMonth)
                barChartData = previousMonthData + currentMonthData
            case .yearly:
                let previousYearData = try await getMonthData(mainCurrency: mainCurrency, year: chartDate.prevYear, month: chartDate.month)
                barChartData = previousYearData + currentMonthData
            }
            self.barChartData = barChartData
        }
    }
    
    func getBarChartListData() -> [ChartData] {
        guard barChartData.count != 0 else {return []}
        let currency = barChartData[0].currency
        let groupedByCategory : [Category : [ChartData]] = Dictionary(grouping: barChartData) { $0.category }
        let differenceByCategory = groupedByCategory.map { (key: Category, value: [ChartData]) in
            let currentSum = value.first { $0.month == chartDate.month && $0.year == chartDate.year }?.sum ?? 0
            let previousSum = value.first { $0.month != chartDate.month || $0.year != chartDate.year }?.sum ?? 0
            let difference = currentSum-previousSum
            var percent = 0
            if previousSum != 0 { percent = Int(((Double(currentSum) / Double(previousSum)) - 1.0) * 100.0) }
            return ChartData(category: key, currency: currency, sum: difference, month: chartDate.month, year: chartDate.year, percentDiff: percent)
        }
        return differenceByCategory.sorted { $0.sum > $1.sum }
    }
        
}


