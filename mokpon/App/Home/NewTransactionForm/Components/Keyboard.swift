import SwiftUI

struct Keyboard: View {
    
    let onPressDigit: @MainActor(_ number: String) -> Void
    let onPressClear: @MainActor(_ btn: String) -> Void
    let onPressBackspace: @MainActor(_ btn: String) -> Void
    let onSwipeUp: () async throws -> Void

    init(viewModel : NewTransactionViewModel, onSwipeUp: @escaping () async throws -> Void) {
        self.onPressDigit = viewModel.onPressDigit
        self.onPressClear = viewModel.onPressClear
        self.onPressBackspace = viewModel.onPressBackspace
        self.onSwipeUp = onSwipeUp
    }
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
    ]
        
    var body: some View {
        
        LazyVGrid (columns: columns) {
            ForEach(1..<10) { index in
                CalculatorButton(onPress: onPressDigit, text: "\(index)")
            }

            CalculatorButton(onPress: onPressClear, text: "C")
            CalculatorButton(onPress: onPressDigit, text: "0")
            CalculatorButton(onPress: onPressBackspace, systemImage: "arrow.backward.to.line")
        }
        .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
            .onEnded { value in
                switch(value.translation.width, value.translation.height) {
                case (-100...100, ...0):
                    Task {
                        try await onSwipeUp()
                    }
                default:  print("no clue")
                }
            }
        )
    }
}

struct Keyboard_Previews: PreviewProvider {
    static var previews: some View {
        Keyboard(
            viewModel: NewTransactionViewModel(appContext: AppContext()),
            onSwipeUp: {}
        )
        .background(.black)
    }
}
