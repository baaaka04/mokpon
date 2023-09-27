import SwiftUI

struct CategoryExpensesView: View {
    
    @StateObject var viewModel: CategoryViewModel
    @AppStorage("mainCurrency") private var mainCurrency : String = "USD"

    var date : ChartsDate
    var category : Category
    
    init(currencyRatesService: CurrencyManager, chartsManager: ChartsManager, directoriesManager: DirectoriesManager, date: ChartsDate, category: Category) {
        _viewModel = StateObject(wrappedValue: CategoryViewModel(currencyRatesService: currencyRatesService, chartsManager: chartsManager, directoriesManager: directoriesManager))
        self.date = date
        self.category = category
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
                        isClickable: false,
                        directoriesManager: viewModel.directoriesManager //will never initiated
                    )
                }
            } else { ProgressView().frame(maxWidth: .infinity) }
        }
        .background(Color.bg_main)
        .task {
            viewModel.getCategoryExpenses(category: category, currencyName: mainCurrency, date: date)
        }
    }
}

struct SubcategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryExpensesView(
            currencyRatesService: CurrencyManager(completion: {}),
            chartsManager: ChartsManager(),
            directoriesManager: DirectoriesManager(completion: {}),
            date: ChartsDate(month: 9, year: 2023),
            category: Category(id: "", name: "", icon: "", type: .expense)
        )
        .foregroundColor(.white)
    }
}
