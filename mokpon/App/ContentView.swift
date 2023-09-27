import SwiftUI

struct ContentView: View {
    
    let authManager: AuthenticationManager
    let userManager: UserManager
    let directoriesManager: DirectoriesManager
    
    @State var currentRoute: Route = .home
    @Binding var showSignInView: Bool
    @StateObject var globalViewModel : GlobalViewModel
    let currencyRatesService = CurrencyManager(completion: {})
    let transactionManager = TransactionManager()
    let amountManager = AmountManager()
    
    init(authManager: AuthenticationManager, userManager: UserManager,  showSignInView: Binding<Bool>, directoriesManager: DirectoriesManager) {
        self.authManager = authManager
        self.userManager = userManager
        self.directoriesManager = directoriesManager
        _showSignInView = showSignInView
        _globalViewModel = StateObject(wrappedValue: GlobalViewModel(directoriesManager: directoriesManager))
    }
        
    var body: some View {
        NavigationView {
            GeometryReader{ geo in
                
                ZStack {
                    BackgroundCloud(posX: 30, posY: -140, width: 700, height: 450)
                    
                    switch currentRoute {
                    case .home:
                        Home(currencyRatesService: currencyRatesService, transactionManager: transactionManager, amountManager: amountManager, authManager: authManager, directoriesManager: directoriesManager)
                    case .charts:
                        Charts(currencyRatesService: currencyRatesService, directoriesManager: directoriesManager)
                    case .settings:
                        SettingsView(showSingInView: $showSignInView, authManager: authManager, userManager: userManager)
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
        ContentView(authManager: AuthenticationManager(), userManager: UserManager(), showSignInView: .constant(true), directoriesManager: DirectoriesManager(completion: {}))
    }
}
