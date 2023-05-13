import SwiftUI
import Charts

struct Charts: View {
    
    @StateObject private var viewModel = ChartsViewModel()
    
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(.black.opacity(0.7))], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(.black.opacity(0.7))], for: .normal)
    }
    
    var body: some View {
        
        VStack{
            Text("Charts")
                .font(.title3.width(.expanded))
                .foregroundColor(.white)
            
            ChartsNavBarView(chartType: $viewModel.selectedChart)
            
            ScrollView {
                
                VStack {
                    ChartsHeaderView(
                        chartDate: $viewModel.chartDate,
                        compareData: $viewModel.compareData,
                        selectedChart: viewModel.selectedChart,
                        fetchData: viewModel.fetchChartsData
                    )
                    
                    Spacer()
                    
                    switch viewModel.selectedChart {
                    case .bar:
                        
                        BarChartView(
                            comparation: viewModel.compareData,
                            chartData: viewModel.chartData,
                            chartDataList: viewModel.chartDataList,
                            getTotals: viewModel.getTotals
                        )
                        
                    case .pie:
                        
                        let sortedPieData = viewModel.chartDataList.monthly.sorted { a, b in a.curSum > b.curSum }
                        PieChartView(
                            values: sortedPieData.map({ expense in Double(expense.curSum) }),
                            colors: [.blue, .green, .orange, .red, .yellow, .cyan, .mint, .pink, .teal, .brown, .purple, .black],
                            names: sortedPieData.map{ $0.category},
                            backgroundColor: .gray
                        )
                        .frame(width: 230, height: 230)
                    }
                }
                .frame(height: 350)
                .padding()
                .background(.gray.opacity(0.7))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .task {
                    await viewModel.fetchChartsData()
                }
                
                ExpensesListView(
                    listData : viewModel.compareData == .monthly
                    ? viewModel.chartDataList.monthly
                    : viewModel.chartDataList.yearly,
                    chartType: viewModel.selectedChart,
                    chartDate: viewModel.chartDate
                )
                
            }
        }
        .font(.custom("DMSans-Regular", size: 16))
    }
}

struct Charts_Previews: PreviewProvider {
    static var previews: some View {
        Charts()
            .frame(maxHeight: .infinity)
            .background(Color.bg_main)
    }
}

