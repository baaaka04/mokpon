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
                    BarMark(
                        x: .value("Month", databar.date),
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
        BarChartView(comparation: .monthly, chartData: .init(monthly: [BarChartData](), yearly: [BarChartData]()), chartDataList: .init(monthly: [BarChartDatalist](), yearly: [BarChartDatalist]()), getTotals: {(a,b) in return [Int]()})
    }
}
