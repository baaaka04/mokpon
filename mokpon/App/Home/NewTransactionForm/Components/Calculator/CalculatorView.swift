import SwiftUI

struct OperationKey : Identifiable {
    let id = UUID()
    let action : String
    let iconName : String
}

struct CalculatorView: View {
    
    var onPressOperationButton : @MainActor(_ key: String) -> Void
    
    let operationKeys : [OperationKey] = [
        .init(action: "+", iconName: "plus"),
        .init(action: "-", iconName: "minus"),
        .init(action: "/", iconName: "divide"),
        .init(action: "*", iconName: "multiply"),
        .init(action: "=", iconName: "equal"),
    ]
    
    var body: some View {
        
        HStack (spacing: 20){
            ForEach(operationKeys) { btn in
                CalculatorButton(onPress: onPressOperationButton, calcButtonName: btn ).font(.custom("DMSans-Regular", size: 26))
            }
        }
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView(onPressOperationButton: { key in return})
    }
}
