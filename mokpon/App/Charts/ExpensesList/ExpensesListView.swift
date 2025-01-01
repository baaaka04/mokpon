import SwiftUI

struct ExpensesListView: View {
    var expenses: [ChartData]
    var selectedType: ChartType
    var selectedPeriod: ChartsDate
    var isClickable: Bool
    
    @AppStorage("mainCurrency") private var mainCurrency: String = "USD"
            
    var body: some View {
        
        VStack(spacing: 10) {
            HStack {
                Text(self.selectedType == .bar ? "Differences" : "Expenses")
                Spacer()
            }
            .font(.custom("DMSans-Regular", size: 20))
            .padding(20)
            
            ForEach(expenses) { chartData in
                if chartData.sum != 0 {
                    switch selectedType {
                    case .bar:
                        ExpenseView(expenseBarData: chartData)
                    case .pie:
                        ExpenseView(
                            expensePieData: chartData,
                            selectedPeriod: selectedPeriod,
                            isClickable: isClickable
                        )
                    }
                }
            }
        }
        .padding(.horizontal)
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
