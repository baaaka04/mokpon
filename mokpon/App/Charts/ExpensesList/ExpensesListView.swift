import SwiftUI

struct ExpensesListView: View {
    var expenses: [ChartData]
    var selectedType: ChartType
    var selectedPeriod: ChartsDate
    var isClickable: Bool
    @State private var selectedCategory: CategoryEnum? = nil
    @EnvironmentObject private var rootViewModel: RootTabViewModel
    
    @AppStorage("mainCurrency") private var mainCurrency: Currency = .usd
            
    var body: some View {
        
        VStack(spacing: 10) {
            HStack {
                Text(self.selectedType == .bar ? "Differences" : "Expenses")
                Spacer()
            }
            .font(.custom("DMSans-Regular", size: 20))
            .padding()

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
                            let percent = chartData.percentDiff ?? 0
                            let subtitle = "Difference: \(percent > 0 ? "+" : "")\(percent)%"
                            
                            let rawNum = chartData.sum
                            let difference = "\(rawNum >= 0 ? "+" : "")\(rawNum.formatted())\(chartData.currency.symbol)"
                            
                            ExpenseView(
                                title: chartData.category.name,
                                subtitle: subtitle,
                                icon: chartData.category.icon,
                                number: difference
                            )
                        case .pie:
                            let title = isClickable ? chartData.category.name : (chartData.subcategory ?? "")
                            let subtitle = "\(DateFormatter().monthSymbols[selectedPeriod.currentPeriod.month-1].capitalized) \(selectedPeriod.currentPeriod.year)"
                            let number = "\(chartData.sum.formatted())\(chartData.currency.symbol)"
                            ExpenseView(
                                title: title,
                                subtitle: subtitle,
                                icon: chartData.category.icon,
                                number: number
                            ) {
                                if isClickable { selectedCategory = chartData.category }
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 140)
        .background(Color.bg_transactions)
        .foregroundColor(.init(white: 0.87))
        .padding(.top, 20)
        .popover(item: $selectedCategory) { category in
            CategoryExpensesView(
                date: selectedPeriod,
                category: category,
                categoryViewModel: rootViewModel.chartsViewModel.categoryViewModel
            )
            .presentationDragIndicator(.visible)
        }
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
        .padding(.horizontal)
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
