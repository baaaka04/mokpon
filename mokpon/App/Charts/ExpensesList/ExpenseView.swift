import SwiftUI

struct ExpenseView : View {
    
    @State var showCategoryExpenses : Bool = false
    @EnvironmentObject private var rootViewModel: RootTabViewModel
    
    var viewData : ExpenseData // data to render
    var selectedPeriod : ChartsDate
    var isClickable : Bool
        
    //BarChart initializer
    init(expenseBarData: ChartData) {
        self.selectedPeriod = ChartsDate(month: 1, year: 2020)
        self.isClickable = false
        
        let number = expenseBarData.sum
        let percent = expenseBarData.percentDiff ?? 0
        self.viewData = ExpenseData(
            title: expenseBarData.category.name,
            subtitle: "Difference: \(percent > 0 ? "+" : "")\(percent)%",
            number: "\(number >= 0 ? "+" : "")\(number.formatted())\(expenseBarData.currency.symbol)",
            category: expenseBarData.category
        )
    }
    //PieChart initializer
    init(expensePieData: ChartData, selectedPeriod: ChartsDate, isClickable: Bool) {
        self.isClickable = isClickable
        self.selectedPeriod = selectedPeriod
        self.viewData = ExpenseData(
            title: expensePieData.category.name,
            subtitle: "\(DateFormatter().monthSymbols[selectedPeriod.currentPeriod.month-1].capitalized) \(selectedPeriod.currentPeriod.year)",
            number: "\(expensePieData.sum.formatted())\(expensePieData.currency.symbol)",
            category: expensePieData.category
        )
    }
    //Simple transaction view initializer
    init(transaction: Transaction) {
        self.selectedPeriod = ChartsDate(month: 1, year: 2020)
        self.isClickable = false
        self.viewData = ExpenseData(
            title: transaction.subcategory,
            subtitle: transaction.date.formatted(.dateTime.day().month().year()),
            number: "\(transaction.sum)\(transaction.currency.symbol)",
            category: transaction.category
        )
    }
    
    var body: some View {
        
        HStack (alignment: .center) {
            Image(systemName: viewData.category.icon)
                .frame(width: 50, height: 50)
                .background(.gray.opacity(0.4))
                .clipShape(Circle())
            VStack (alignment: .leading) {
                Text(String(viewData.title))
                Text(viewData.subtitle).font(.caption)
            }
            Spacer()
            
            Text(viewData.number)
                .frame(width: 90, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(white: 0.2), lineWidth: 1)
                )
        }
        .padding()
        .background(Color.bg_main)
        .cornerRadius(20)
        .popover(isPresented: $showCategoryExpenses) {
            CategoryExpensesView(
                date: selectedPeriod,
                category: viewData.category,
                categoryViewModel: rootViewModel.chartsViewModel.categoryViewModel
            )
            .presentationDragIndicator(.visible)
        }
        .onTapGesture {
            isClickable ? showCategoryExpenses.toggle() : nil
        }
    }
}

struct ExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseView(expensePieData: ChartData(category: Category(id: "cat-01", name: "food", icon: "cart", type: .expense), currency: Currency(id: "", name: "", symbol: ""), sum: -123, month: 8, year: 2023), selectedPeriod: ChartsDate(month: 9, year: 2023), isClickable: false)
            .font(.custom("DMSans-Regular", size: 13))
            .foregroundColor(.white)
    }
}
