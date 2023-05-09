import SwiftUI

struct Keyboard: View {
    
    let onPressDigit: (_ number: Int) -> Void
    let onPressClear: () -> Void
    let onPressBackspace: () -> Void
    let onSwipeUp: () -> Void
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
    ]
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        LazyVGrid (columns: columns) {
            ForEach(1..<10) { index in
                
                Button(
                    action: { onPressDigit(index) },
                    label: { Text(String(index)).frame(maxWidth: .infinity) }
                )
            }
            .frame(height: 64)
            
            Button(action: onPressClear) { Text("C") }.frame(height: 64)
            Button(action: { onPressDigit(0) }) { Text(String(0)) }.frame(height: 64)
            Button(action: onPressBackspace) { Image(systemName: "arrow.backward.to.line") }.frame(height: 64)
            
        }
        .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
            .onEnded { value in
                switch(value.translation.width, value.translation.height) {
                case (-100...100, ...0):  onSwipeUp()
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
            onPressClear: { },
            onPressBackspace: { },
            onSwipeUp: {}
        ).background(.black)
    }
}
