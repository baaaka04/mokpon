import SwiftUI

struct NumberPad: View {
    
    var sum : Int
    var type : ExpensesType
    var currency : Currency?
    var switchCurrency : () -> Void
    var onSwipeRight : () -> Void
    var isExchange : Bool
    
    var body: some View {
        HStack {
            Text(self.type == .income || self.isExchange ? "" : "-")
            Spacer()
            HStack {
                Text(currency?.symbol ?? "n/a")
                    .onTapGesture {
                        switchCurrency()
                    }
                Spacer()
                Text("\(sum)")
                    .lineLimit(1)
            }
        }
        .minimumScaleFactor(0.3)
        .padding(.vertical, 30)
        .font(.custom("gothicb", size: 62))
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .local)
            .onEnded { value in
                if value.translation.width > 0 {
                    onSwipeRight()
                }
            }
        )
    }
}

struct NumberPad_Previews: PreviewProvider {
    static var previews: some View {
        NumberPad(sum: 0, type: .expense, currency: Currency(id: "cur-01", name: "USD", symbol: "$"), switchCurrency: {}, onSwipeRight: {}, isExchange: true)
    }
}
