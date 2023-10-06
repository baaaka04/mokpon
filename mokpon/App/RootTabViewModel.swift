import Foundation


@MainActor
final class RootTabViewModel : ObservableObject {
    
    let homeViewModel : HomeViewModel
    let chartsViewModel : ChartsViewModel
    let settingsViewModel : SettingsViewModel
    
    @Published var categories : [Category]? = nil
    @Published var currencies : [Currency]? = nil
    
    init(appContext: AppContext) {
        self.homeViewModel = HomeViewModel(appContext: appContext)
        self.chartsViewModel = ChartsViewModel(appContext: appContext)
        self.settingsViewModel = SettingsViewModel(appContext: appContext)
        Task {
            self.categories = try await appContext.directoriesManager.getAllCategories()
        }
        Task {
            self.currencies = try await appContext.directoriesManager.getAllCurrencies()
        }
    }
}
