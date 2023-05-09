import Foundation

class ChartsViewModel : ObservableObject {
    
    @Published var chartData = ComparationChart(monthly: [BarChartData](), yearly: [BarChartData]())
    @Published var chartDataList = ComparationList(monthly: [BarChartDatalist](), yearly: [BarChartDatalist]())
    
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
    func fetchChartsData () -> Void {
        guard let url = URL(string: "http://212.152.40.222:50401/api/chartDataSwiftUI") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(DTScharts(month: String(chartDate.month), year: String(chartDate.year)))
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil,
                  let resData = data
            else {
                print("error calling POST on /newRow/")
                print(error!)
                return
            }
                        
            guard
                let jsonDecoded : APIChartsResponse = try? JSONDecoder().decode(
                    APIChartsResponse.self,
                    from: resData
                )
            else {
                print("Decoder error")
                return
            }
            
            DispatchQueue.main.async {
                self.chartData = jsonDecoded.barChartData
                self.chartDataList = jsonDecoded.barChartDatalist
            }
        }
        .resume()
    }
    
}
