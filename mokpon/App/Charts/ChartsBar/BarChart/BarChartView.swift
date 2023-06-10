import SwiftUI
import Charts

struct BarChartView: View {
    
    var comparation : Comparation
    var chartData : ComparationChart
    var chartDataList : ComparationList
    var getTotals : (_ chartDataList: ComparationList, _ comparation: Comparation) -> [Int]
    
    var body: some View {
        if chartData.monthly.count == 0 {
            ProgressView().padding(100)
        } else {
            Chart {
                ForEach (comparation == .monthly ? chartData.monthly : chartData.yearly) {databar in
                    let year : Int = Int(databar.date.dropLast(3)) ?? 2023
                    let month : Int = Int(databar.date.dropFirst(5)) ?? 12
                    
                    BarMark(
                        x: .value("Month", getChartMonthName(year: year, month: month)),
                        y: .value("Rub", databar.sum)
                    )
                    .foregroundStyle(by: .value("Category", databar.category))
                }
                .annotation(content: {
                    HStack {
                        ForEach(getTotals(chartDataList, comparation).filter{$0 != 0}, id: \.self) { sum in
                            Text("\(sum)")
                                .frame(width: 150)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .foregroundColor(.white)
                })
            }
            .chartYAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .leading) { AxisValueLabel() }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { AxisValueLabel().foregroundStyle(.white) }
            }
        }
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartView(comparation: .monthly, chartData: .init(monthly: [
            ChartData(category: "test", sum: 22, date: "2022-04"),
            ChartData(category: "test2", sum: 223, date: "2022-04"),
            ChartData(category: "test", sum: 200, date: "2022-05"),
            ChartData(category: "test2", sum: 35, date: "2022-05")
        ], yearly: [ChartData]()), chartDataList: .init(monthly: [ChartDatalist](), yearly: [ChartDatalist]()), getTotals: {(a,b) in return [Int]()})
        .background(.gray)
    }
}
