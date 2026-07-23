import SwiftUI

struct DebitCard: View {

    let cardholderName: String?
    var amounts: [Amount]? = nil
    let directoriesManager: DirectoriesManager
    
    var body: some View {
        ZStack {
            ZStack {
                HStack {
                    Image("Chip")
                    Image("Wireless")
                    if let amounts {
                        VStack(alignment: .trailing) {
                            ForEach(amounts, id: \.curId) { amount in
                                Text("\(amount.curId.symbol) \(amount.sum)")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .font(.title)
                            .padding(.leading, 30)
                        }
                    } else { ProgressView() }
                }
                
                VStack {
                    Spacer()
                    HStack (alignment: .bottom){
                        Text(cardholderName?.uppercased() ?? "CARDHOLDER")
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
        .frame(height: 230)
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
        .padding(.horizontal)
    }
}

struct DebitCard_Previews: PreviewProvider {
    static var previews: some View {
        DebitCard(
            cardholderName: "John Smith",
            amounts: [
                .init(curId: .kgs, sum: 400),
                .init(curId: .rub, sum: 2400),
                .init(curId: .usd, sum: 132400)
            ], directoriesManager: DirectoriesManager())
        .foregroundColor(.white)
        .font(.custom("DMSans-Regular", size: 18))
    }
}
