import SwiftUI

struct ExpenseView : View {
    
    @StateObject var viewModel = СategoryExpensesViewModel() // TODO: delete
    @State var showCategoryExpenses : Bool = false
    
    var viewData : ExpenseData // data to render
    
    var expense : ChartDatalist? // data to get
    var expenseDate : ChartsDate // data to get
    var isClickable : Bool // data to get
    
    //BarChart initializer
    init(expenseBarData: ChartDatalist, isClickable: Bool, expenseDate: ChartsDate) {
        self.expense = expenseBarData
        self.isClickable = isClickable
        self.expenseDate = expenseDate
        
        let curSum = expenseBarData.curSum
        let prevSum = expenseBarData.prevSum
        let diff = curSum - prevSum
        var percent : Int = 0
        if prevSum != 0 { percent = Int(((Double(curSum) / Double(prevSum)) - 1.0) * 100.0) }
        self.viewData = ExpenseData(
            categoryIcon: expenseBarData.category,
            title: expenseBarData.category,
            subtitle: "₽ \(diff.formatted())",
            number: String(percent) + "%"
        )
    }
    //PieChart initializer
    init(expensePieData: ChartDatalist, isClickable: Bool, expenseDate: ChartsDate) {
        self.expense = expensePieData
        self.isClickable = isClickable
        self.expenseDate = expenseDate
        
        self.viewData = ExpenseData(
            categoryIcon: expensePieData.category,
            title: expensePieData.category,
            subtitle: "\(DateFormatter().monthSymbols[expenseDate.month-1].capitalized) \(expenseDate.year)",
            number: "₽ \(expensePieData.curSum.formatted())"
        )
    }
    //Simple transaction view initializer
    init(transaction: Transaction) {
        self.expenseDate = .init(month: 1, year: 2000)
        self.isClickable = false
        self.viewData = ExpenseData(
            categoryIcon: transaction.category.icon,
            title: transaction.subcategory,
            subtitle: transaction.date.formatted(.dateTime.day().month().year()),
            number: "\(transaction.sum)\(transaction.currency.symbol)"
        )
    }
    
    var body: some View {
        
        HStack (alignment: .center) {
            Image(systemName: viewData.categoryIcon ?? "questionmark")
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
            CategoryExpensesView(viewData: viewModel.categoryExpenses, date: expenseDate, title: viewData.title)
        }
        .onTapGesture {
            Task {
                isClickable ? await openSubcategoryView() : nil
            }
        }
    }
    
    func openSubcategoryView () async -> Void {
        showCategoryExpenses = true
        await viewModel.getCategoryExpenses(category: viewData.title, monthYear: expenseDate)
        
    }
}

struct ExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseView(expensePieData: ChartDatalist(category: "питание", prevSum: 0, curSum: 123), isClickable: true, expenseDate: ChartsDate(month: 6, year: 2023))
            .font(.custom("DMSans-Regular", size: 13))
            .foregroundColor(.white)
    }
}
