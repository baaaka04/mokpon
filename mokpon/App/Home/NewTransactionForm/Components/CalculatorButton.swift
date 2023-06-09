import SwiftUI

enum Symbol {
    case text,image,calcButton
}

struct CalculatorButton: View {
    
    @State var isPressed : Bool = false
    var text : String = ""
    var action : String = "="
    var size : CGFloat = 70
    let onPress : (_ btn : String) -> Void
    let symbol : Symbol
    
    init(onPress: @escaping (_: String) -> Void, text: String) {
        self.onPress = onPress
        self.symbol = .text
        self.text = text
    }
    init(onPress: @escaping (_: String) -> Void, systemImage: String) {
        self.onPress = onPress
        self.symbol = .image
        self.text = systemImage
    }
    init(onPress: @escaping (_: String) -> Void, calcButtonName: OperationKey) {
        self.onPress = onPress
        self.symbol = .calcButton
        self.text = calcButtonName.iconName
        self.action = calcButtonName.action
        self.size = 50
    }
    
    
    var body: some View {
        Button(
            action: {
                isPressed = true
                switch symbol {
                case .text,.image:
                    onPress(text)
                case .calcButton:
                    onPress(action)
                }
                withAnimation {
                    isPressed = false
                }
            },
            label: {
                ZStack {
                    Capsule()
                        .frame(width: size, height: size)
                        .foregroundColor(.accentColor)
                        .opacity(
                            isPressed ? 0.7 : 0
                        )
                    switch symbol {
                    case .text:
                        Text(String(text)).frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .image,.calcButton:
                        Image(systemName: text).frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        )
    }
}

struct CalculatorButton_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorButton(onPress: {btn in return} ,text: "2")
    }
}
