import SwiftUI

struct ExpensesListView: View {
    var expenses : [ChartData]
    var selectedType : ChartType
    var selectedPeriod : ChartsDate
    var isClickable : Bool
    
    @AppStorage("mainCurrency") private var mainCurrency : String = "USD"
    
    private func getBarchartData (chartData: [ChartData]) -> [ChartData] {
        guard let currency = DirectoriesManager.shared.getCurrency(byName: mainCurrency) else {return []}
        let groupedByCategory : [Category : [ChartData]] = Dictionary(grouping: chartData) { $0.category }
        let differenceByCategory = groupedByCategory.map { (key: Category, value: [ChartData]) in
            let currentSum = value.first { $0.month == selectedPeriod.month && $0.year == selectedPeriod.year }?.sum ?? 0
            let previousSum = value.first { $0.month != selectedPeriod.month || $0.year != selectedPeriod.year }?.sum ?? 0
            let difference = currentSum-previousSum
            var percent = 0
            if previousSum != 0 { percent = Int(((Double(currentSum) / Double(previousSum)) - 1.0) * 100.0) }
            return ChartData(category: key, currency: currency, sum: difference, month: selectedPeriod.month, year: selectedPeriod.year, percentDiff: percent)
        }
        return differenceByCategory.sorted { $0.sum > $1.sum }
    }
    
    var body: some View {
        
        VStack (spacing: 10) {
            HStack {
                Text(self.selectedType == .bar ? "Differences" : "Expenses")
                Spacer()
            }
            .font(.custom("DMSans-Regular", size: 20))
            .padding(20)
            switch selectedType {
            case .bar:
                ForEach(getBarchartData(chartData: expenses)) { chartData in
                    ExpenseView(expenseBarData: chartData)
                        .padding(.horizontal)
                }
            case .pie:
                ForEach(expenses) { chartData in
                    if chartData.sum != 0 {
                        ExpenseView(expensePieData: chartData, selectedPeriod: selectedPeriod, isClickable: isClickable)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 140)
        .background(Color.bg_transactions)
        .foregroundColor(.init(white: 0.87))
        .padding(.top, 20)
    }
}

struct ExpensesListView_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesListView(
            expenses: [ ],
            selectedType: .pie,
            selectedPeriod: ChartsDate(month: 6, year: 2023),
            isClickable: false
        )
        
    }
}
