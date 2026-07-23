import Foundation


@MainActor
final class RootTabViewModel: ObservableObject {
    
    private let appContext = AppContext()
    let homeViewModel: HomeViewModel
    let chartsViewModel: ChartsViewModel
    let authViewModel: AuthViewModel

    init() {
        self.homeViewModel = HomeViewModel(appContext: appContext)
        self.chartsViewModel = ChartsViewModel(appContext: appContext)
        self.authViewModel = AuthViewModel(appContext: appContext)
    }
}
