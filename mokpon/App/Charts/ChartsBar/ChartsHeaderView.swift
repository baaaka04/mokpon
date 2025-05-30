import SwiftUI

struct ChartsHeaderView: View {
    
    @Binding var chartDate: ChartsDate
    @Binding var compareData: Comparation
    var selectedChart: ChartType
    var fetchData: () async -> Void

    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text("Expenses")
                    .font(.custom("DMSans-Regular", size: 20))
                Text(getChartMonthName(year: chartDate.currentPeriod.year, month: chartDate.currentPeriod.month))
            }
            
            Spacer()
            VStack {
                Picker("", selection: $compareData.animation(.easeInOut) ) {

                    ForEach(Comparation.allCases, id: \.self) { compareData in
                        Text(compareData.rawValue)
                            .tag(compareData)
                    }
                }
                .disabled(selectedChart == .pie)
                .pickerStyle(.segmented)
                .background(.white.opacity(0.5))
                .cornerRadius(8)
                .onChange(of: compareData) { _ in getChartsData() }

                HStack {
                    
                    Button {
                        chartDate.decreaseMonth()
                        getChartsData()
                    } label: {
                        Image(systemName: "arrowtriangle.backward.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .padding(5)
                    .padding(.horizontal, 15)
                    .background(.white)
                    .cornerRadius(5)
                    
                    Button {
                        chartDate.increaseMonth()
                        getChartsData()
                    } label: {
                        Image(systemName: "arrowtriangle.forward.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .padding(5)
                    .padding(.horizontal, 15)
                    .background(.white)
                    .cornerRadius(5)
                }
                .foregroundColor(.gray)
            }
            .frame(width: 200)

        }
    }

    private func getChartsData() {
        Task {
            await fetchData()
        }
    }
}

struct ChartsHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsHeaderView(chartDate: .constant(ChartsDate(month: 1, year: 2023)), compareData: .constant(.monthly), selectedChart: .bar, fetchData: {return})
            .background(.black.opacity(0.7))
    }
}
