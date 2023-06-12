import SwiftUI

struct ExpensesListView: View {
    var listData : [ChartDatalist]
    var chartType : ChartSelected
    var chartDate : ChartsDate
    var isClickable : Bool
    
    var pieChartDatalist: [ChartDatalist] {
        return self.listData.sorted { $0.curSum > $1.curSum }
    }
    
    var body: some View {
        
        VStack (spacing: 10) {
            HStack {
                switch self.chartType {
                case .bar:
                    Text("Differences")
                case .pie:
                    Text("Expenses")
                }
                Spacer()
            }
            .font(.custom("DMSans-Regular", size: 20))
            .padding(20)
            switch chartType {
            case .bar:
                ForEach(0..<self.listData.count, id: \.self) { i in
                    ExpenseView(expenseBarData: self.listData[i], isClickable: self.isClickable, expenseDate: self.chartDate)
                        .padding(.horizontal)
                }
            case .pie:
                ForEach(0..<self.pieChartDatalist.count, id: \.self) { i in
                    if pieChartDatalist[i].curSum != 0 {
                        ExpenseView(expensePieData: pieChartDatalist[i], isClickable: self.isClickable, expenseDate: self.chartDate)
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
            listData: [
                ChartDatalist(category: "питание", prevSum: 32, curSum: 1200),
                ChartDatalist(category: "pets", prevSum: 23, curSum: 11),
            ],
            chartType: .pie,
            chartDate: ChartsDate(month: 6, year: 2023),
            isClickable: true
        )
        
    }
}
