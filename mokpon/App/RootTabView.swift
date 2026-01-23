import SwiftUI

struct RootTabView: View {
    
    @State private var currentRoute: Route = .home    
    @EnvironmentObject private var rootViewModel: RootTabViewModel

    var body: some View {
        NavigationStack {
            GeometryReader{ geo in
                
                ZStack {
                    BackgroundCloud(posX: 30, posY: -140, width: 700, height: 450)
                    
                    switch currentRoute {
                    case .home:
                        Home(viewModel: rootViewModel.homeViewModel)
                    case .charts:
                        ChartsView(viewModel: rootViewModel.chartsViewModel)
                    case .settings:
                        SettingsView()
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
    struct Preview: View {
        @StateObject private var rootViewModel = RootTabViewModel()

        var body: some View {
            RootTabView()
                .environmentObject(rootViewModel)
        }
    }

    static var previews: some View {
        Preview()
    }
}
