import SwiftUI

struct RootTabView: View {
    
    @State private var currentRoute: Route = .home
    @Binding private var showSignInView: Bool
    
    @StateObject private var rootTabViewModel: RootTabViewModel
    
    init(showSignInView: Binding<Bool>, viewModel: RootTabViewModel) {
        _showSignInView = showSignInView
        _rootTabViewModel = StateObject(wrappedValue: viewModel)
    }
        
    var body: some View {
        NavigationStack {
            GeometryReader{ geo in
                
                ZStack {
                    BackgroundCloud(posX: 30, posY: -140, width: 700, height: 450)
                    
                    switch currentRoute {
                    case .home:
                        Home(viewModel: rootTabViewModel.homeViewModel)
                    case .charts:
                        ChartsView(viewModel: rootTabViewModel.chartsViewModel)
                    case .settings:
                        SettingsView(
                            showSingInView: $showSignInView,
                            viewModel: rootTabViewModel.settingsViewModel
                        )
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
        .environmentObject(rootTabViewModel)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView(showSignInView: .constant(false), viewModel: RootTabViewModel(appContext: AppContext()))
    }
}
