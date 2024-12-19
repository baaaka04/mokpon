import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class TransactionManager {
    
    init() {print("\(Date()): INIT TransactionManager")}
    deinit {print("\(Date()): DEINIT TransactionManager")}
    
    private let transactionCollection = Firestore.firestore().collection("transactions") //if there's no collection in db, it will create it
    
    // Use a dictionary instead of a struct because we need Document ID generated on Firebase
    func createNewTransaction(transaction: Transaction, userId: String) async throws -> String {
        let documentRef = try await transactionCollection.addDocument(data: [
            "category_id" : transaction.category.id,
            "subcategory" : transaction.subcategory.lowercased(),
            "type" : transaction.type.rawValue,
            "date" : transaction.date,
            "sum" : transaction.sum,
            "currency_id" : transaction.currency.id,
            "deleted" : false,
            "user_id" : userId
        ])
        let documentId = documentRef.documentID
        try await transactionCollection.document(documentId).updateData(["id":documentId])
        return documentId
    }
        
    func getLastNTransactions(limit: Int, lastDocument: DocumentSnapshot? = nil, searchText: String = "", selectedCategoryId: String? = nil) async -> (documents: [DBTransaction], lastDocument: DocumentSnapshot?) {
        do {
            var query = transactionCollection
                .whereField(DBTransaction.CodingKeys.subcategory.rawValue, isGreaterThanOrEqualTo: searchText)
                .whereField(DBTransaction.CodingKeys.subcategory.rawValue, isLessThanOrEqualTo: searchText + "\u{f8ff}")
                .whereField(DBTransaction.CodingKeys.deleted.rawValue, isEqualTo: false)
                .order(by: DBTransaction.CodingKeys.date.rawValue, descending: true)
                .limit(to: limit)
                .startOptionally(afterDocument: lastDocument)

            // Add category filter if selectedCategoryId is not nil
            if let selectedCategoryId {
                query = query.whereField(DBTransaction.CodingKeys.categoryId.rawValue, isEqualTo: selectedCategoryId)
            }
            print("Transactions has been downloaded")
            return try await query.getDocumentsWithSnapshot(as: DBTransaction.self)
        } catch {
            print(error)
            return ([], nil)
        }
    }
    
    func deleteTransaction (transactionId: String) async throws {
        try await transactionCollection.document(transactionId).updateData(["deleted":true])
    }
    
    func getHotkeys() async throws -> [DBHotkey] {
        let (FBTransactions, _) = await getLastNTransactions(limit: 300)
           return Dictionary(grouping: FBTransactions, by: {DBHotkey(categoryId: $0.categoryId, subcategory: $0.subcategory, count: 0)})
                .map { (key, arr) in DBHotkey(categoryId: key.categoryId, subcategory: key.subcategory, count: arr.count) }
                .sorted { $0.count > $1.count }
    }
    
}
struct DBHotkey : Hashable {
    let categoryId: String
    let subcategory: String
    let count: Int
}

struct DBTransaction : Decodable {
    let id : String
    let categoryId : String
    let subcategory : String
    let type : ExpensesType
    let date : Date
    var sum : Int
    var currencyId : String
    let deleted : Bool
    let userId : String
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case subcategory
        case type
        case date
        case sum
        case currencyId = "currency_id"
        case deleted
        case userId = "user_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.categoryId = try container.decode(String.self, forKey: .categoryId)
        self.subcategory = try container.decode(String.self, forKey: .subcategory)
        self.type = try container.decode(ExpensesType.self, forKey: .type)
        self.date = try container.decode(Date.self, forKey: .date)
        self.sum = try container.decode(Int.self, forKey: .sum)
        self.currencyId = try container.decode(String.self, forKey: .currencyId)
        self.deleted = try container.decode(Bool.self, forKey: .deleted)
        self.userId = try container.decode(String.self, forKey: .userId)
    }
}
