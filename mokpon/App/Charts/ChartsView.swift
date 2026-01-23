import SwiftUI
import Charts

struct ChartsView: View {

    @StateObject private var viewModel: ChartsViewModel
    @State private var error: Error?

    @AppStorage("mainCurrency") private var mainCurrency: String = "USD"

    init(viewModel: ChartsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)

        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(.black.opacity(0.7))], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(.black.opacity(0.7))], for: .normal)
    }

    var body: some View {

        VStack {
            Text("Charts")
                .font(.title3.width(.expanded))

            ChartsNavBarView(chartType: $viewModel.selectedChart)

            ScrollView {
                chartsPanel

                ExpensesListView(
                    expenses: viewModel.selectedChart == .bar ? viewModel.getBarChartListData() : viewModel.pieChartData,
                    selectedType: viewModel.selectedChart,
                    selectedPeriod: viewModel.chartDate,
                    isClickable: viewModel.selectedChart == .pie
                )
            }
            .scrollIndicators(.hidden)
        }
        .font(.custom("DMSans-Regular", size: 16))
        
    }

    private var chartsPanel: some View {
        VStack {
            ChartsHeaderView(
                chartDate: $viewModel.chartDate,
                compareData: $viewModel.compareData,
                selectedChart: viewModel.selectedChart,
                fetchData: loadChartsData
            )

            if let error = error as? AppError {
                Text(error.description)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !viewModel.pieChartData.isEmpty {
                TabView(selection: $viewModel.selectedChart) {
                    PieChartView(chartData: viewModel.pieChartData)
                        .frame(width: 230, height: 230)
                        .tag(ChartType.pie)
                    BarChartView(chartData: viewModel.barChartData)
                        .tag(ChartType.bar)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            } else {
                ChartSkeletonView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task {
                        await loadChartsData()
                    }
            }


        }
        .frame(minHeight: 350, maxHeight: 500)
        .padding()
        .background(.gray.opacity(0.7))
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }

    @MainActor
    private func loadChartsData() async {
        do {
            self.error = nil
            try await viewModel.getChartsData(currencyName: mainCurrency)
        } catch let error {
            self.error = error
        }
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

