import SwiftUI

struct BackgroundCloud: View {
    
    let posX: CGFloat?
    let posY: CGFloat?
    let width: CGFloat?
    let height: CGFloat?
    
    init(posX: CGFloat? = nil, posY: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil) {
        self.posX = posX
        self.posY = posY
        self.width = width
        self.height = height
    }
    
    var body: some View {
        Rectangle()
            .fill(
                EllipticalGradient(
                    gradient: Gradient(colors: [
                        Color.bg_secondary,
                        Color.bg_main
                    ]),
                    center: .center,
                    startRadiusFraction: 0.01,
                    endRadiusFraction: 0.5
                )
            )
            .frame(width: width, height: height)
            .position(x: posX ?? UIScreen.main.bounds.width/2, y: posY ?? UIScreen.main.bounds.height/2)
            .opacity(0.5)
    }
}

struct BackgroundCloud_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundCloud(posX: 0, posY: 0, width: 100, height: 100)
    }
}
