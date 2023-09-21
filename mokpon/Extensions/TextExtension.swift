import SwiftUI

extension Text {

    func gradient() -> some View {
        self.foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient:
                        Gradient(colors: [
                            Color.addbutton_secondary,
                            Color.addbutton_main,
                        ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Color.white.opacity(0.5),lineWidth: 1)
            )
    }
}
