import Foundation

@MainActor
final class GlobalViewModel : ObservableObject {
    @Published var categories : [Category]? = nil
    @Published var currencies : [Currency]? = nil
    
    init () {
        Task {
            self.categories = try await DirectoriesManager.shared.getAllCategories()
        }
        Task {
            self.currencies = try await DirectoriesManager.shared.getAllCurrencies()
        }
    }
    
}
