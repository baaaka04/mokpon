import SwiftUI

struct ExpenseView : View {
    
    var viewData : ExpenseData
    var expense : ChartDatalist
    var expenseDate : ChartsDate
    
    @State var isSubcategoryShowed : Bool = false
    @StateObject var viewModel = SubcategoryViewModel()
    var isClickable : Bool
    
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
            title: expensePieData.category,
            subtitle: "\(DateFormatter().monthSymbols[expenseDate.month-1].capitalized) \(expenseDate.year)",
            number: "₽ \(expensePieData.curSum.formatted())"
        )
    }
    
    var body: some View {
        
        HStack (alignment: .center) {
            Image(systemName: categories[viewData.title] ?? "questionmark")
                .frame(width: 50, height: 50)
                .background(.gray.opacity(0.4))
                .clipShape(Circle())
            VStack (alignment: .leading) {
                Text(String(viewData.title))
                Text(viewData.subtitle).font(.caption)
            }
            Spacer()
            
            VStack{
                Text(viewData.number)
            }
            .frame(width: 90, height: 44)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(white: 0.2), lineWidth: 1)
            )
        }
        .padding()
        .frame(width: 350, height: 80)
        .background(Color.bg_main)
        .cornerRadius(20)
        .popover(isPresented: $isSubcategoryShowed) {
            SubcategoryView(viewData: viewModel.categoryExpenses, date: expenseDate)
        }
        .onTapGesture {
            Task {
                isClickable ? await openSubcategoryView() : nil
            }
        }
    }
    
    func openSubcategoryView () async -> Void {
        isSubcategoryShowed = true
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
