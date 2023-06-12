import SwiftUI

struct ContentView: View {
    
    @State var currentRoute: Route = .home
    
    var body: some View {
        NavigationView {
            GeometryReader{ geo in
                
                ZStack {
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
                        .frame(width: 700, height: 450)
                        .position(x: 30, y: -140)
                        .opacity(0.5)
                    
                    switch currentRoute {
                    case .home:
                        Home()
                    case .charts:
                        Charts()
                    case .settings:
                        VStack{
                            Text("Settings")
                                .font(.title3.width(.expanded))
                            Spacer()
                        }
                    }
                    VStack{
                        Spacer()
                        NavBarView(currentRoute: $currentRoute, size: geo.size)
                    }
                }
                
            }
            .background(Color.bg_main)
            .foregroundColor(.white)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
