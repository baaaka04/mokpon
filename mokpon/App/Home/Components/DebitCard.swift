import SwiftUI

struct DebitCard: View {
    
    var body: some View {
        ZStack {
            VStack{
                Spacer()
                
                HStack{
                    Image("Chip")
                    Image("Wireless")
                    Spacer()
                    Text("₽23 504")
                        .font(.title)
                }
                .padding()
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
                .padding()
            }
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
        DebitCard()
            .foregroundColor(.white)
            .font(.custom("DMSans-Regular", size: 18))
    }
}
