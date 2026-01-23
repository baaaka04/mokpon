import SwiftUI

struct AddButton: View {
        
    var body: some View {
        
        Circle()
            .strokeBorder(Color.white.opacity(0.5),lineWidth: 1)
            .frame(width: 44, height: 44)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            gradient:
                                Gradient(colors: [
                                    Color.addbutton_main,
                                    Color.addbutton_secondary,
                                ]
                                        ),
                            startPoint: .trailing,
                            endPoint: .leading
                        )
                    )
            )
            .overlay(Text("+")
                .font(.custom("DMSans-Regular", size: 24))
                .foregroundColor(.white.opacity(0.87))
            )
    }
    
}


struct AddButton_Previews: PreviewProvider {
    static var previews: some View {
        AddButton()
    }
}
