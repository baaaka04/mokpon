import SwiftUI

struct ExpenseView : View {

    let title: String
    let subtitle: String
    let icon: String
    let number: String
    var onTap: (() -> Void)?

    var body: some View {
        
        HStack(alignment: .center) {
            Image(systemName: icon)
                .frame(width: 50, height: 50)
                .background(.gray.opacity(0.4))
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(title)
                Text(subtitle).font(.caption)
            }
            
            Spacer()
            
            Text(number)
                .frame(width: 90, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(white: 0.2), lineWidth: 1)
                )
        }
        .padding()
        .background(Color.bg_main)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal)
        .onTapGesture {
            onTap?()
        }
    }
}

struct ExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ExpenseView(title: "питание", subtitle: "Тестовое название", icon: "cart", number: "100")
            ExpenseView(title: "питание", subtitle: "Тестовое название", icon: "cart", number: "200")
        }
        .font(.custom("DMSans-Regular", size: 13))
        .foregroundColor(.white)
        .padding()
    }
}
