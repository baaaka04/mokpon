import SwiftUI

struct ContentView: View {
    
    @State var currentRoute: Route = .home
    @Binding var showSignInView: Bool
    @StateObject var directiriesViewModel = DirectoriesManager()
    
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
                        SettingsView(showSingInView: $showSignInView)
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
        .environmentObject(directiriesViewModel)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(showSignInView: .constant(true))
    }
}
