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
    
    func getCategory(byName name: String) -> Category? {
        guard let categories else {return nil}
        return categories.first { $0.name == name }
    }
    
    func getCategory (byID id: String) -> Category? {
        guard let categories else {return nil}
        return categories.first { $0.id == id }
    }
    
    func getCurrency(byID id: String) -> Currency? {
        guard let currencies else {return nil}
        return currencies.first { $0.id == id }
    }
    
    func getCurrency(byName name: String) -> Currency? {
        guard let currencies else {return nil}
        return currencies.first { $0.name == name }
    }
}
