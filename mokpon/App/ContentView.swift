import SwiftUI

struct ContentView: View {
    
    @State var currentRoute: Route = .home
    @Binding var showSignInView: Bool
    @StateObject var globalViewModel = GlobalViewModel()
    
    var body: some View {
        NavigationView {
            GeometryReader{ geo in
                
                ZStack {
                    BackgroundCloud(posX: 30, posY: -140, width: 700, height: 450)
                    
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
        .environmentObject(globalViewModel)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(showSignInView: .constant(true))
    }
}
