import SwiftUI

struct CategoryExpensesView: View {
    
    @StateObject private var viewModel: CategoryViewModel
    @AppStorage("mainCurrency") private var mainCurrency: Currency = .usd
    
    var date: ChartsDate
    var category: CategoryEnum
    
    init(date: ChartsDate, category: CategoryEnum, categoryViewModel: CategoryViewModel) {
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
        .scrollIndicators(.hidden)
        .background(Color.bg_main)
        .task {
            viewModel.getCategoryExpenses(currency: mainCurrency, date: date, category: category)
        }
    }
}

struct SubcategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryExpensesView(date: ChartsDate(month: 10, year: 2023), category: .cat01, categoryViewModel: CategoryViewModel(appContext: AppContext()))
        .foregroundColor(.white)
    }
}
