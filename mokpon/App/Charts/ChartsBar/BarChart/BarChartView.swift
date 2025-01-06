import SwiftUI


struct BarChartView: View {

    private var chartData: [ChartData]
    @State private var excludedCategories: Set<Category> = []

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

    init(chartData: [ChartData]) {
        self.chartData = chartData.sorted {$0.sum < $1.sum }
    }

    var body: some View {

        VStack {
            HStack(alignment: .bottom) {
                ForEach(periods, id: \.self) { period in
                    snackBar(period: period, columnCount: CGFloat(periods.count))
                }
            }
            legend
        }
        .animation(.default, value: excludedCategories)
        .font(.custom("DMSans-Regular", size: 10))
        .foregroundStyle(.white)
        .padding()

    }

    private func snackBar(period: ChartsDate, columnCount: CGFloat) -> some View {
        let maxColumnWidth: CGFloat = 300
        let maxColumnHeight: CGFloat = 130
        let periodData = self.chartData
            .filter { $0.month == period.currentPeriod.month && $0.year == period.currentPeriod.year }
            .filter { !excludedCategories.contains($0.category) }
        let periodTotal = periodData.reduce(0) { $0 + $1.sum }

        return VStack {
            Text("\(periodTotal) \(currency)")

            VStack(spacing: 0) {
                ForEach(periodData, id: \.id) { chartData in
                    ZStack {
                        let barHeight: CGFloat = CGFloat(chartData.sum)/self.maxHeight * maxColumnHeight
                        let barWidth: CGFloat = maxColumnWidth/columnCount
                        Rectangle()
                            .frame(maxWidth: barWidth, maxHeight: barHeight)
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
        let columns = [GridItem(.adaptive(minimum: 60))]

        return LazyVGrid(columns: columns) {
            ForEach(categories, id: \.self) { category in

                Button(
                    action: {
                        if excludedCategories.contains(category) {
                            excludedCategories.remove(category)
                        } else {
                            excludedCategories.insert(category)
                        }
                    },
                    label: {
                        Text("\(category.name)")
                            .frame(width: 60)
                            .lineLimit(1)
                            .padding(3)
                            .background(
                                category.color
                                    .opacity(excludedCategories.contains(category) ? 0.3 : 1)
                            )
                            .cornerRadius(5)
                    }
                )

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
