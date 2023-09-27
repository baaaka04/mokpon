import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class DirectoriesManager {
    var categories : [Category]? = nil
    var currencies : [Currency]? = nil
    
    init (completion: @escaping () -> Void) {
        Task {
            self.categories = try await getAllCategories()
            completion()//a completion handler to access methods of the class after 'async' init
        }
        Task {
            self.currencies = try await getAllCurrencies()
            completion()//a completion handler to access methods of the class after 'async' init
        }
        print("\(Date()): INIT DirectoriesManager")
    }
    
    deinit {
        print("\(Date()): DEINIT DirectoriesManager")
    }
        
    private let categoriesCollection = Firestore.firestore().collection("categories") //if there is no collection in db, it will be created
    private let currenciesCollection = Firestore.firestore().collection("currencies")
    
    func getAllCategories () async throws -> [Category] {
        print("\(Date()): DirectoriesManager: categories has been loaded")
        return try await categoriesCollection.getDocuments(as: Category.self)
    }
    
    func getAllCurrencies () async throws -> [Currency] {
        print("\(Date()): DirectoriesManager: currencies has been loaded")
        return try await currenciesCollection.getDocuments(as: Currency.self)
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


