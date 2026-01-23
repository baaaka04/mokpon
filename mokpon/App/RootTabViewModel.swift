import Foundation


@MainActor
final class RootTabViewModel: ObservableObject {
    
    private let appContext = AppContext()
    let homeViewModel: HomeViewModel
    let chartsViewModel: ChartsViewModel
    let authViewModel: AuthViewModel

    @Published var categories: [Category]? = nil
    @Published var currencies: [Currency]? = nil
    @Published var isLoading: Bool = true

    init() {
        self.homeViewModel = HomeViewModel(appContext: appContext)
        self.chartsViewModel = ChartsViewModel(appContext: appContext)
        self.authViewModel = AuthViewModel(appContext: appContext)
    }

    func loadRequirements() {
        Task {
            let categories = try await appContext.directoriesManager.getAllCategories()
            self.categories = categories
            appContext.directoriesManager.categories = categories

            let currencies = try await appContext.directoriesManager.getAllCurrencies()
            self.currencies = currencies
            appContext.directoriesManager.currencies = currencies
            print("Requirements has been loaded")
            self.isLoading = false
        }
    }

}
