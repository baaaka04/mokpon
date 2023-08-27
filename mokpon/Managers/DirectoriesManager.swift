import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class DirectoriesManager : ObservableObject {
        
    @Published var categories : [Category] = []
    @Published var currencies : [Currency]? = nil
    
    init () {
        Task {
            self.categories = try await getAllCategories()
        }
        Task {
            self.currencies = try await getAllCurrencies()
        }
    }
    
    private let categoriesCollection = Firestore.firestore().collection("categories") //if there is no collection in db, it will be created
    private let currenciesCollection = Firestore.firestore().collection("currencies")
    
    private func getAllCategories () async throws -> [Category] {
        try await categoriesCollection.getDocuments(as: Category.self)
    }
    
    private func getAllCurrencies () async throws -> [Currency] {
        try await currenciesCollection.getDocuments(as: Currency.self)
    }
    
    func getCategory (byName name: String) -> Category? {
        self.categories.first { $0.name == name }
    }
}

struct Category : Codable, Identifiable {
    let id : String
    let name : String
    let icon : String
    let type : ExpensesType
}

struct Currency : Codable, Identifiable {
    let id : String
    let name : String
    let symbol : String
}
