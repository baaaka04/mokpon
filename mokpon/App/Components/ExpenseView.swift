import SwiftUI

struct ExpenseView : View {
    
    @StateObject var viewModel = СategoryExpensesViewModel()
    @State var showCategoryExpenses : Bool = false
    
    var viewData : ExpenseData // data to render
    
    var expense : ChartDatalist? // data to get
    var expenseDate : ChartsDate // data to get
    var isClickable : Bool // data to get
    var isLast : Bool? // data to get
    var isLoading : Bool? // data to get
    
    
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
            systemImageName: expenseBarData.category,
            title: expenseBarData.category,
            subtitle: "₽ \(diff.formatted())",
            number: String(percent) + "%"
        )
    }
    
    init(expensePieData: ChartDatalist, isClickable: Bool, expenseDate: ChartsDate) {
        self.expense = expensePieData
        self.isClickable = isClickable
        self.expenseDate = expenseDate

        self.viewData = ExpenseData(
            systemImageName: expensePieData.category,
            title: expensePieData.category,
            subtitle: "\(DateFormatter().monthSymbols[expenseDate.month-1].capitalized) \(expenseDate.year)",
            number: "₽ \(expensePieData.curSum.formatted())"
        )
    }
    
    init(transaction: Transaction, isLast: Bool, isLoading: Bool) {
        self.expenseDate = .init(month: 1, year: 2000)
        self.isClickable = false
        self.isLast = isLast
        self.isLoading = isLoading
        
        self.viewData = ExpenseData(
            systemImageName: transaction.category,
            title: transaction.subCategory,
            subtitle: transaction.date.formatted(.dateTime.day().month().year()),
            number: "₽ \(transaction.sum)"
        )
    }
        
    var body: some View {
        
        HStack (alignment: .center) {
            Image(systemName: categories[viewData.systemImageName] ?? "questionmark")
                .frame(width: 50, height: 50)
                .background(.gray.opacity(0.4))
                .clipShape(Circle())
            VStack (alignment: .leading) {
                Text(String(viewData.title))
                Text(viewData.subtitle).font(.caption)
            }
            Spacer()
            
            VStack{
                if self.isLast ?? false {
                    Text(viewData.number)
                        .onAppear {
                            //isLoading = true - добавить в функцию пагинации
//                            isLoading ? print("load data") : print("loading. pls wait")
                            //isLoading = false - добавить в функцию пагинации
                        }
                } else {
                    Text(viewData.number)
                }
            }
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
