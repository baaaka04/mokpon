import Foundation

@MainActor
final class GlobalViewModel : ObservableObject {
    @Published var categories : [Category]? = nil
    @Published var currencies : [Currency]? = nil
    
    
    init (directoriesManager: DirectoriesManager) {
        Task {
            self.categories = try await directoriesManager.getAllCategories()
        }
        Task {
            self.currencies = try await directoriesManager.getAllCurrencies()
        }
        print("\(Date()): INIT GlobalViewModel")
    }
    deinit {print("\(Date()): DEINIT GlobalViewModel")}
    
}
