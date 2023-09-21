import SwiftUI

struct DebitCard: View {
    
    var amounts : [Amount]? = nil
    
    var body: some View {
        ZStack {
            ZStack{
                HStack {
                    HStack {
                        Image("Chip")
                        Image("Wireless")
                    }
                    Spacer()
                    VStack {
                        if let amounts {
                            ForEach(amounts, id: \.curId) { amount in
                                HStack {
                                    let currency = DirectoriesManager.shared.getCurrency(byID: amount.curId)
                                    Spacer(minLength: 0)
                                    Text("\(currency?.symbol ?? "?") \(amount.sum)")
                                }
                                .font(.title)
                                .padding(.leading, 30)
                            }
                        } else { ProgressView() }
                    }
                }
                VStack {
                    Spacer()
                    HStack (alignment: .bottom){
                        Text("ARTEM BEREZIN")
                        Spacer()
                        ZStack{
                            Circle()
                                .frame(width:45)
                                .foregroundColor(.red.opacity(0.7))
                                .offset(x:12)
                            Circle()
                                .frame(width:45)
                                .foregroundColor(.orange.opacity(0.7))
                                .offset(x:-12)
                        }
                        .frame(width: 75)
                    }
                }
            }
            .padding()
        }
        .frame(width: 320, height: 230)
        .background(
            LinearGradient(
                gradient:
                    Gradient(colors: [
                        Color.card_secondary,
                        Color.card_main,
                    ]
                            ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
    }
}

struct DebitCard_Previews: PreviewProvider {
    static var previews: some View {
        DebitCard(amounts: [
            .init(curId: "cur-01", sum: 400),
            .init(curId: "cur-02", sum: 2400),
            .init(curId: "cur-03", sum: 132400)
        ])
            .foregroundColor(.white)
            .font(.custom("DMSans-Regular", size: 18))
    }
}
