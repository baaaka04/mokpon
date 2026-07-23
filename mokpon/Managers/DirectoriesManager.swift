import Foundation
import FirebaseFirestore

final class DirectoriesManager {
    var categories : [Category] = Category.all
    
    init () {
        print("\(Date()): INIT DirectoriesManager")
    }
    
    deinit {
        print("\(Date()): DEINIT DirectoriesManager")
    }

    func getCategory(byName name: String) -> Category? {
        return categories.first { $0.name == name }
    }
    
    func getCategory (byID id: String) -> Category? {
        return categories.first { $0.id == id }
    }
}


