import SwiftUI

struct ExpensesListView: View {
    var listData : [BarChartDatalist]
    var chartType : ChartSelected
    var chartDate : ChartsDate
    
    var expenses: [ExpenseData] {
        var tempExpenses: [ExpenseData] = []
        
        for (i, _) in listData.enumerated() {
            var subtitle : String = ""
            var number : String = ""
            let curSum = self.listData[i].curSum
            let prevSum = self.listData[i].prevSum
            let diff : Int = curSum - prevSum
            var percent : Int = 0
            if prevSum != 0 { percent = Int(((Double(curSum) / Double(prevSum)) - 1.0) * 100.0) }
            switch self.chartType {
            case .bar :
                subtitle = "₽ \(diff.formatted())"
                number = String(percent) + "%"
            case .pie :
                subtitle = "\(DateFormatter().monthSymbols[chartDate.month-1].capitalized) \(chartDate.year)"
                number = "₽ \(curSum.formatted())"
            }
            
            tempExpenses.append(
                ExpenseData(
                    title: self.listData[safe: i]?.category ?? "n/a",
                    subtitle: subtitle,
                    number: number
                )
            )
        }
        
        switch self.chartType {
        case .bar:
            return tempExpenses
        case .pie:
            let sorted = tempExpenses.sorted { a, b in
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                let numberA = formatter.number(from: String(a.number.dropFirst(2)))?.intValue ?? 0
                let numberB = formatter.number(from: String(b.number.dropFirst(2)))?.intValue ?? 0
                return numberA > numberB
            }
            return sorted
        }
    }

    
    var body: some View {
        
        VStack{
            ForEach(0..<self.listData.count, id: \.self) { i in
                if expenses[i].number != "₽ 0" {
                    ExpenseView(expenseData: self.expenses[i])
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.bottom, 40)
        .background(Color.bg_transactions)
        .foregroundColor(.init(white: 0.87))
        .padding(.top, 20)
    }
}

struct ExpensesListView_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesListView(
            listData: [
                BarChartDatalist(category: "food", prevSum: 32, curSum: 1200),
                BarChartDatalist(category: "pets", prevSum: 23, curSum: 11),
                ],
            chartType: .pie,
            chartDate: ChartsDate(month: 3, year: 2023))
        
    }
}
