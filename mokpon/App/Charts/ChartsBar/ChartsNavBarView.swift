import SwiftUI

struct ChartsNavBarView: View {
    
    @Binding var chartType : ChartSelected
    
    var body: some View {
        
        VStack {
            
            HStack (alignment: .center) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        if chartType == .bar { chartType = .pie }
                    }
                } label: {
                    Text("Pie")
                        .foregroundColor(chartType == .bar ? .white : .yellow)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if chartType == .pie { chartType = .bar }
                    }
                } label: {
                    Text("Bar")
                        .foregroundColor(chartType == .bar ? .yellow : .white)
                        .frame(maxWidth: .infinity)
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
