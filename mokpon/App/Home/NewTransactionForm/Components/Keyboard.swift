import SwiftUI

struct Keyboard: View {
    
    let onPressDigit: (_ number: String) -> Void
    let onPressClear: (_ btn: String) -> Void
    let onPressBackspace: (_ btn: String) -> Void
    let onSwipeUp: () async -> Void
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
    ]
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        LazyVGrid (columns: columns) {
            ForEach(1..<10) { index in
                CalculatorButton(onPress: onPressDigit, text: "\(index)")
            }
            .frame(height: 64)
            
            CalculatorButton(onPress: onPressClear, text: "C").frame(height: 64)
            CalculatorButton(onPress: onPressDigit, text: "0").frame(height: 64)
            CalculatorButton(onPress: onPressBackspace, systemImage: "arrow.backward.to.line").frame(height: 64)
        }
        .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
            .onEnded { value in
                switch(value.translation.width, value.translation.height) {
                case (-100...100, ...0):  Task {await onSwipeUp()}
                default:  print("no clue")
                }
            }
        )
    }
}

struct Keyboard_Previews: PreviewProvider {
    static var previews: some View {
        Keyboard(
            onPressDigit: { thb in return},
            onPressClear: {btn in return },
            onPressBackspace: {btn in return },
            onSwipeUp: {}
        ).background(.black)
    }
}
