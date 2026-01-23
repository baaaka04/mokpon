import SwiftUI

struct ChartsNavBarView: View {

    @Binding var chartType: ChartType

    var body: some View {

        VStack {

            HStack (alignment: .center) {
                ForEach(ChartType.allCases, id: \.self) { type in
                    Button {
                        chartType = type
                    } label: {
                        Text(type.rawValue.capitalized)
                            .foregroundColor(chartType == type ? .yellow : .white)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(maxWidth: 400)
            .overlay(
                HStack{
                    if chartType == .bar { Spacer() }
                    Rectangle()
                        .frame(width: 170, height: 1, alignment: .bottom)
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow, radius: 1)
                        .shadow(color: .yellow, radius: 1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: chartType)
                    if chartType == .pie { Spacer() }
                }
                ,
                alignment: .bottom
            )
            .padding(.horizontal)
        }
    }
}

struct ChartsNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsNavBarView(chartType: .constant(.bar))
            .background(.black)
    }
}
