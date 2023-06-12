import SwiftUI

struct CategoryExpensesView: View {
    
    var viewData : [ChartDatalist]
    var date : ChartsDate
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                PieChartView(
                    values: viewData.map({ item in
                        Double(item.curSum)
                    }),
                    colors: Color.palette,
                    names: viewData.map({ item in
                        item.category
                    }),
                    backgroundColor: Color.bg_main
                )
                .padding(70)
                .frame(height: 350)
                
                ExpensesListView(
                    listData: viewData,
                    chartType: .pie,
                    chartDate: date,
                    isClickable: false
                )
            }
        }
        .background(Color.bg_main)
    }
}

struct SubcategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryExpensesView(viewData:
            [
            .init(category: "здоровая пища", prevSum: 0, curSum: 140),
            .init(category: "всячина", prevSum: 0, curSum: 70),
            .init(category: "кафе", prevSum: 0, curSum: 50),
            ], date: ChartsDate(month: 6, year: 2023))
    }
}
