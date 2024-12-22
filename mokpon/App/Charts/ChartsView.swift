import SwiftUI
import Charts

struct ChartsView: View {
    
    @StateObject private var viewModel: ChartsViewModel
    @AppStorage("mainCurrency") private var mainCurrency : String = "USD"
    
    init(viewModel: ChartsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        
        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(.black.opacity(0.7))], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(.black.opacity(0.7))], for: .normal)
    }
        
    var body: some View {
        
        VStack{
            Text("Charts")
                .font(.title3.width(.expanded))
            
            ChartsNavBarView(chartType: $viewModel.selectedChart)
            
            ScrollView {
                
                VStack {
                    ChartsHeaderView(
                        chartDate: $viewModel.chartDate,
                        compareData: $viewModel.compareData,
                        selectedChart: viewModel.selectedChart,
                        fetchData: {
                            viewModel.getPieChartData(mainCurrency: mainCurrency)
                            viewModel.getBarChartData(mainCurrency: mainCurrency)
                        }
                    )
                    
                    Spacer()

                    if viewModel.pieChartData.count == 0 {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        switch viewModel.selectedChart {
                        case .bar:
                            BarChartView(chartData: viewModel.barChartData)
                        case .pie:
                            PieChartView(chartData: viewModel.pieChartData)
                                .frame(width: 230, height: 230)
                        }
                    }
                }
                .frame(minHeight: 350, maxHeight: 500)
                .padding()
                .background(.gray.opacity(0.7))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .task {
                    viewModel.getPieChartData(mainCurrency: mainCurrency)
                    viewModel.getBarChartData(mainCurrency: mainCurrency)
                }
                
                ExpensesListView(
                    expenses : viewModel.selectedChart == .bar ? viewModel.getBarChartListData() : viewModel.pieChartData,
                    selectedType: viewModel.selectedChart,
                    selectedPeriod: viewModel.chartDate,
                    isClickable: viewModel.selectedChart == .pie
                )
                
            }
            .scrollIndicators(.hidden)
        }
        .font(.custom("DMSans-Regular", size: 16))
    }
}

struct Charts_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView(viewModel: ChartsViewModel(appContext: AppContext()))
            .foregroundColor(.white)
            .frame(maxHeight: .infinity)
            .background(Color.bg_main)
    }
}

