import SwiftUI

struct ChartsHeaderView: View {
    
    @Binding var chartDate : ChartsDate
    @Binding var compareData : Comparation
    var selectedChart : ChartSelected
    var fetchData : () -> Void
    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text("Expenses")
                    .font(.custom("DMSans-Regular", size: 20))
                Text("\(DateFormatter().monthSymbols[chartDate.month-1].capitalized)'\(String(String(chartDate.year).dropFirst(2)))")
            }
            .foregroundColor(.white)
            
            Spacer()
            VStack {
                Picker("", selection: $compareData.animation(.easeInOut) ) {
                    Text("Month")
                        .tag(Comparation.monthly)
                    Text("Year")
                        .tag(Comparation.yearly)
                }
                .disabled(selectedChart == .pie)
                .pickerStyle(.segmented)
                .background(.white.opacity(0.5))
                .cornerRadius(8)
                .frame(width: 150)
                
                HStack {
                    
                    Button {
                        chartDate.decreaseMonth()
                        fetchData()
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
                        fetchData()
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
                .frame(width: 150)
            }
            
        }
        
    }
}

struct ChartsHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsHeaderView(chartDate: .constant(ChartsDate(month: 1, year: 2023)), compareData: .constant(.monthly), selectedChart: .bar, fetchData: {return})
            .background(.black.opacity(0.7))
    }
}
