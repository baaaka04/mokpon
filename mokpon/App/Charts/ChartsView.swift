import SwiftUI
import Charts

struct Charts: View {
    
    @StateObject private var viewModel = ChartsViewModel()
    @AppStorage("mainCurrency") private var mainCurrency : String = "USD"
    
    init() {
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
                    
                    switch viewModel.selectedChart {
                    case .bar:
                        BarChartView(barChartData: viewModel.barChartData)
                    case .pie:
                        PieChartView(chartData: viewModel.pieChartData)
                            .frame(width: 230, height: 230)
                    }
                }
                .frame(height: 350)
                .padding()
                .background(.gray.opacity(0.7))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .task {
                    viewModel.getPieChartData(mainCurrency: mainCurrency)
                    viewModel.getBarChartData(mainCurrency: mainCurrency)
                }
                
                ExpensesListView(
                    expenses : viewModel.selectedChart == .bar ? viewModel.barChartData : viewModel.pieChartData,
                    selectedType: viewModel.selectedChart,
                    selectedPeriod: viewModel.chartDate,
                    isClickable: viewModel.selectedChart == .pie
                )
                
            }
        }
        .font(.custom("DMSans-Regular", size: 16))
    }
}

struct Charts_Previews: PreviewProvider {
    static var previews: some View {
        Charts()
            .foregroundColor(.white)
            .frame(maxHeight: .infinity)
            .background(Color.bg_main)
    }
}

