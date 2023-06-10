import Foundation

class ChartsViewModel : ObservableObject {
    
    @Published var chartData = ComparationChart(monthly: [ChartData](), yearly: [ChartData]())
    @Published var chartDataList = ComparationList(monthly: [ChartDatalist](), yearly: [ChartDatalist]())
    
    @Published var selectedChart : ChartSelected = .bar
    @Published var compareData : Comparation = .monthly
    
    var chartDate : ChartsDate = ChartsDate(
        month: Calendar.current.component(.month, from: Date()),
        year: Calendar.current.component(.year, from: Date())
    )
// calculate totals for barcharts
    func getTotals (chartDataList: ComparationList, comparation: Comparation) -> [Int] {
        var curSum = 0
        var prevSum = 0
        
        switch comparation {
        case .monthly:
            curSum = chartDataList.monthly.reduce(0, {$0 + $1.curSum})
            prevSum = chartDataList.monthly.reduce(0, {$0 + $1.prevSum})
        case .yearly:
            curSum = chartDataList.yearly.reduce(0, {$0 + $1.curSum})
            prevSum = chartDataList.yearly.reduce(0, {$0 + $1.prevSum})
        }
        return [prevSum, curSum]
    }
// POST-request to get charts' data
    func fetchChartsData () async -> Void {
        let fetchedData = await APIService.shared.fetchChartsData(month: String(chartDate.month), year: String(chartDate.year))
        await MainActor.run {
            self.chartData = fetchedData.chartData
            self.chartDataList = fetchedData.chartDatalist
        }
    }
        
}
