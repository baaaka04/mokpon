import Foundation

@MainActor
final class ChartsViewModel: ObservableObject {
    
    @Published var selectedChart: ChartType = .bar
    @Published var compareData: Comparation = .monthly
    
    @Published var pieChartData: [ChartData] = []
    @Published var barChartData: [ChartData] = []

    private var isLoading: Bool = false
    let categoryViewModel: CategoryViewModel
    
    private(set) var currencyRatesService: CurrencyManager
    private(set) var chartsManager: ChartsManager
    private(set) var directoriesManager: DirectoriesManager
    private(set) var authManager: AuthenticationManager

    var chartDate: ChartsDate = ChartsDate(
        month: Calendar.current.component(.month, from: Date()),
        year: Calendar.current.component(.year, from: Date())
    )
    
    init(appContext: AppContext) {
        self.currencyRatesService = appContext.currencyRatesService
        self.chartsManager = appContext.chartsManager
        self.directoriesManager = appContext.directoriesManager
        self.authManager = appContext.authManager
        self.categoryViewModel = CategoryViewModel(appContext: appContext)
        print("\(Date()): INIT ChartsViewModel")
    }
    deinit {print("\(Date()): DEINIT ChartsViewModel")}
        
    private func convertTransactionsCurrency(transactions: [DBTransaction], currency: Currency) -> [DBTransaction] {
        let transInMainCurrency = transactions.compactMap { trs -> DBTransaction? in
            var newTrs = trs
            guard let oldCurrency = directoriesManager.getCurrency(byID: trs.currencyId) else {return nil}
            newTrs.sum = currencyRatesService.convertCurrency(value: trs.sum, from: oldCurrency.name, to: currency.name) ?? 0
            newTrs.currencyId = currency.id
            return newTrs
        }
        return transInMainCurrency
    }
    
    private func getMonthData(currencyName: String, year: Int, month: Int, forMonths: Int = 1) async throws -> [ChartData] {
        guard let currency = directoriesManager.getCurrency(byName: currencyName) else {return []}
        let user = try authManager.getAuthenticatedUser()
        let transactions: [DBTransaction] = try await chartsManager.getTransactions(userId: user.uid, year: year, month: month, forMonths: forMonths)
        //convert expenses into main currency
        let transInMainCurrency = convertTransactionsCurrency(transactions: transactions, currency: currency)
        //groupBy category
        let chartsData = getTotalsByCategory(transactions: transInMainCurrency, currency: currency)
        return chartsData
            .filter{ dataRow in dataRow.category.type != .income && dataRow.category.type != .exchange }
            .sorted { $0.sum > $1.sum }
    }

    func getTotalsByCategory(transactions: [DBTransaction], currency: Currency) -> [ChartData] {
        var aggregation: [String: Int] = [:]

        for item in transactions {
            let chartsDate = ChartsDate(date: item.date)

            let key = "\(chartsDate.currentPeriod.year)^\(chartsDate.currentPeriod.month)^\(item.categoryId)"
            aggregation[key, default: 0] -= item.sum
        }

        let result = aggregation.compactMap { (key, sum) -> ChartData? in
            let components = key.split(separator: "^")
            let categoryId = String(components[2])
            guard let yearNum = Int(components[0]),
                  let monthNum = Int(components[1]),
                  let category = directoriesManager.getCategory(byID: categoryId) else { return nil }
            return ChartData(category: category, currency: currency, sum: sum, month: monthNum, year: yearNum)
        }

        return result
    }

    func getPieChartData(currencyName: String) {
        guard !self.isLoading else { return }
        self.isLoading = true
        Task {
            self.pieChartData = try await getMonthData(currencyName: currencyName, year: chartDate.currentPeriod.year, month: chartDate.currentPeriod.month)
            self.isLoading = false
        }
    }
    
    func getBarChartData(currencyName: String) {
        guard !self.isLoading else { return }
        self.isLoading = true
        Task {
            var barChartData: [ChartData] = []
            let currentMonthData = try await getMonthData(currencyName: currencyName, year: chartDate.currentPeriod.year, month: chartDate.currentPeriod.month)

            switch compareData {
            case .monthly:
                let previousMonthData = try await getMonthData(currencyName: currencyName, year: chartDate.previousMonthPeriod.year, month: chartDate.previousMonthPeriod.month)
                barChartData = previousMonthData + currentMonthData
            case .yearly:
                let previousYearData = try await getMonthData(currencyName: currencyName, year: chartDate.previousYearPeriod.year, month: chartDate.currentPeriod.month)
                barChartData = previousYearData + currentMonthData
            case .fiveMonth:
                barChartData = try await getMonthData(currencyName: currencyName, year: chartDate.currentPeriod.year, month: chartDate.currentPeriod.month, forMonths: 5)
            }
            self.barChartData = barChartData
            self.isLoading = false
        }
    }

    func getBarChartListData() -> [ChartData] {
        guard !barChartData.isEmpty else { return [] }

        let currency = barChartData[0].currency
        let groupedByCategory = Dictionary(grouping: barChartData, by: { $0.category })

        func calculateDifferenceAndPercent(currentSum: Int, previousSum: Int) -> (difference: Int, percent: Int) {
            let difference = currentSum - previousSum
            let percent = previousSum != 0 ? Int(((Double(currentSum) / Double(previousSum)) - 1.0) * 100.0) : 0
            return (difference, percent)
        }

        let differenceByCategory = groupedByCategory.compactMap { (key, value) -> ChartData? in
            let (currentSum, previousSum): (Int, Int)

            switch compareData {
            case .monthly, .fiveMonth:
                currentSum = value.first {
                    $0.month == chartDate.currentPeriod.month && $0.year == chartDate.currentPeriod.year
                }?.sum ?? 0
                previousSum = value.first {
                    $0.month == chartDate.previousMonthPeriod.month && $0.year == chartDate.previousMonthPeriod.year
                }?.sum ?? 0
            case .yearly:
                currentSum = value.first {
                    $0.month == chartDate.currentPeriod.month && $0.year == chartDate.currentPeriod.year
                }?.sum ?? 0
                previousSum = value.first {
                    $0.month == chartDate.previousYearPeriod.month && $0.year == chartDate.previousYearPeriod.year
                }?.sum ?? 0
            }

            let (difference, percent) = calculateDifferenceAndPercent(currentSum: currentSum, previousSum: previousSum)

            return ChartData(
                category: key,
                currency: currency,
                sum: difference,
                month: chartDate.currentPeriod.month,
                year: chartDate.currentPeriod.year,
                percentDiff: percent
            )
        }

        return differenceByCategory.sorted { $0.sum > $1.sum }
    }


}


