import SwiftUI
import Charts

struct BarChartView: View {
    
    var barChartData : [ChartData]
    
    private func getTotals (_ barChartData: [ChartData]) -> [Int] {
        let getStringPeriod : (Int, Int) -> String = { (year, month) in
            "\(year)"+String(format: "%02d",month)
        }
        
        let groupedByPeriod = Dictionary(grouping: barChartData) { getStringPeriod($0.year, $0.month) }
        let sumByPeriod = groupedByPeriod.mapValues { chartData in
            chartData.reduce(0) {$0 + $1.sum}
        }
        let uniquePeriods = Set( barChartData.map{ getStringPeriod($0.year, $0.month) } ).sorted {$0 < $1}
        
        return uniquePeriods.compactMap { sumByPeriod[$0] }
    }
    
    var body: some View {
        if barChartData.count == 0 {
            ProgressView().padding(100)
        } else {
            Chart {
                ForEach (barChartData) {barData in
                    BarMark(
                        x: .value("Month", getChartMonthName(year: barData.year, month: barData.month)),
                        y: .value("Value", barData.sum)
                    )
                    .foregroundStyle(by: .value("Category", barData.category.name))
                }
                .annotation(content: {
                    HStack {
                        ForEach(getTotals(barChartData), id: \.self) { sum in
                            Text("\(sum) \(barChartData[0].currency.symbol)")
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
        BarChartView(
            barChartData: []
        )
        .background(.gray)
    }
}
