import SwiftUI


struct BarChartView: View {

    let chartData: [ChartData]

    private var maxHeight: CGFloat {
        let dict = Dictionary(grouping: chartData) { "\($0.month)" + "\($0.year)" }
        let totalByMonth = dict.mapValues { chartDataForMonth in
            chartDataForMonth.reduce(0) { $0 + $1.sum }
        }
        let maxValue = totalByMonth.map{$0.value}.max()

        return CGFloat(maxValue ?? 0)
    }

    private var periods: [ChartsDate] {
        return Array(Set(chartData.map {
            ChartsDate(month: $0.month, year: $0.year)
        })
            .sorted { $0.currentPeriod.month < $1.currentPeriod.month}
            .sorted {$0.currentPeriod.year < $1.currentPeriod.year}
        )
    }

    private var currency: String {
        Set(chartData.map {$0.currency.symbol}).first ?? ""
    }

    private var categories: [Category] {
        Array(Set(chartData.map { $0.category })).sorted{ $0.id < $1.id }
    }


    var body: some View {

        VStack {
            HStack(alignment: .bottom) {
                ForEach(periods, id: \.self) { period in
                    snackBar(period: period, columnCount: periods.count)
                }
            }
            legend
        }
        .font(.custom("DMSans-Regular", size: 10))
        .foregroundStyle(.white)
        .padding()

    }

    private func snackBar(period: ChartsDate, columnCount: Int) -> some View {
        VStack {
            let periodData = chartData
                .filter { $0.month == period.currentPeriod.month && $0.year == period.currentPeriod.year }
            let periodTotal = periodData.reduce(0) { $0 + $1.sum }
            Text("\(periodTotal) \(currency)")
                .font(.custom("DMSans-Regular", size: 12))


            VStack(spacing: 0) {
                let sortedData = periodData.sorted {$0.sum < $1.sum }
                ForEach(sortedData, id: \.id) { chartData in
                    ZStack {
                        let barHeight = CGFloat(chartData.sum)/maxHeight * 130
                        Rectangle()
                            .frame(maxWidth: CGFloat(300/columnCount), maxHeight: barHeight)
                            .foregroundColor(chartData.category.color)
                        if barHeight > 20 {
                            Text("\(chartData.sum) \(currency)")
                        }
                    }
                }
                let monthAndYear = getChartMonthName(year: period.currentPeriod.year, month: period.currentPeriod.month)
                Text(monthAndYear)
                    .lineLimit(1)
                    .padding(.vertical, 5)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var legend: some View {
        Group {
            let columns = [GridItem(.adaptive(minimum: 60))]

            LazyVGrid(columns: columns) {
                ForEach(categories, id: \.self) { category in
                    Text("\(category.name)")
                        .frame(width: 60)
                        .lineLimit(1)
                        .padding(3)
                        .background(category.color)
                        .cornerRadius(5)
                }
            }
        }
    }


}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        BarChartView(chartData: [
            // data
        ])
    }
}
