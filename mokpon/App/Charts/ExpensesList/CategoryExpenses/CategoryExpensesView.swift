import SwiftUI

struct CategoryExpensesView: View {
    
    @StateObject private var viewModel : CategoryViewModel
    @AppStorage("mainCurrency") private var mainCurrency : String = "USD"
    
    var date : ChartsDate
    var category : Category
    
    init(date : ChartsDate, category : Category, categoryViewModel: CategoryViewModel) {
        self.date = date
        self.category = category
        _viewModel = StateObject(wrappedValue: categoryViewModel)
    }
        
    var body: some View {
        
        ScrollView {
            if !viewModel.pieChartData.isEmpty {
                VStack {
                    Text(category.name.capitalizedSentence)
                        .font(.title2.width(.expanded))
                        .padding(.horizontal)
                        .padding(.top)
                    
                    PieChartView(chartData: viewModel.pieChartData)
                        .padding(.horizontal, 70)
                        .frame(height: 250)
                    
                    ExpensesListView(
                        expenses: viewModel.pieChartData,
                        selectedType: .pie,
                        selectedPeriod: date,
                        isClickable: false
                    )
                }
            } else { ProgressView().frame(maxWidth: .infinity).padding(.top, 200) }
        }
        .background(Color.bg_main)
        .task {
            viewModel.getCategoryExpenses(currencyName: mainCurrency, date: date, category: category)
        }
    }
}

struct SubcategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryExpensesView(date: ChartsDate(month: 10, year: 2023), category: Category(id: "cat01", name: "питание", icon: "cart", type: .expense), categoryViewModel: CategoryViewModel(appContext: AppContext()))
        .foregroundColor(.white)
    }
}
