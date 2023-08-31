import Foundation

@MainActor
final class GlobalViewModel : ObservableObject {
    @Published var categories : [Category]? = nil
    @Published var currencies : [Currency]? = nil
    
    
    init () {
        Task {
            self.categories = try await DirectoriesManager.shared.getAllCategories()
            print("\(Date()): categories has been loaded")
        }
        Task {
            self.currencies = try await DirectoriesManager.shared.getAllCurrencies()
            print("\(Date()): currencies has been loaded")
        }
    }
    
}
