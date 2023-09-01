import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class DirectoriesManager {
    var categories : [Category]? = nil
    var currencies : [Currency]? = nil

    static let shared = DirectoriesManager()
    
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
    
    func getAllCategories () async throws -> [Category] {
        try await categoriesCollection.getDocuments(as: Category.self)
    }
    
    func getAllCurrencies () async throws -> [Currency] {
        try await currenciesCollection.getDocuments(as: Currency.self)
    }
    
    func getCategory(byName name: String) -> Category? {
        guard let categories else {return nil}
        return categories.first { $0.name == name }
    }
    
    func getCategory (byID id: String) -> Category {
        guard let categories else {return Category(id: "cat-00", name: "none", icon: "questionmark", type: .expense)}
        return categories.first { $0.id == id } ?? Category(id: "cat-00", name: "none", icon: "questionmark", type: .expense)
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

struct Category : Codable, Identifiable {
    let id : String
    let name : String
    let icon : String
    let type : ExpensesType
}

struct Currency : Codable, Identifiable, Hashable {
    let id : String
    let name : String
    let symbol : String
}
