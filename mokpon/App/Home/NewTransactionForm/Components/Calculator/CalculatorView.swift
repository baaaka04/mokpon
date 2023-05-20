import SwiftUI


struct CalculatorView: View {
    
    var onPressOperationButton : (_ key: String) -> Void
    
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
