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

            if expenses.isEmpty {
                VStack {
                    ForEach(0..<4) { _ in
                        cell
                    }
                }
            } else {
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
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 140)
        .background(Color.bg_transactions)
        .foregroundColor(.init(white: 0.87))
        .padding(.top, 20)
    }
}

extension ExpensesListView {
    private var cell: some View {
        HStack (spacing: 20) {
            Image(systemName: "questionmark.circle")
                .resizable()
                .frame(width: 50, height: 50)
            Image(systemName: "text.alignleft")
                .resizable()
                .frame(maxWidth: 100)
            Spacer()
            Text("$ ---")
                .frame(width: 90, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(white: 0.2), lineWidth: 1)
                )
        }
        .opacity(0.7)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.bg_main)
        .cornerRadius(15)
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
