import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class TransactionManager {
    
    init() {print("\(Date()): INIT TransactionManager")}
    deinit {print("\(Date()): DEINIT TransactionManager")}
    
    private let transactionCollection = Firestore.firestore().collection("transactions") //if there's no collection in db, it will be created
    
    //use a dictionary instead of a struct because we need Document ID generated on Firebase
    func createNewTransaction(categoryId: String, subcategory: String, type: ExpensesType, date: Date, sum: Int, currencyId: String, userId: String) async throws {
        let documentRef = try await transactionCollection.addDocument(data: [
            "category_id" : categoryId,
            "subcategory" : subcategory.lowercased(),
            "type" : type.rawValue,
            "date" : date,
            "sum" : sum,
            "currency_id" : currencyId,
            "deleted" : false,
            "user_id" : userId
        ])
        let documentId = documentRef.documentID
        try await transactionCollection.document(documentId).updateData(["id":documentId])
    }
        
    func getLastNTransactions(limit: Int, lastDocument: DocumentSnapshot? = nil ) async -> (documents: [DBTransaction], lastDocument: DocumentSnapshot?) {
        do {
            return try await transactionCollection
                .whereField(DBTransaction.CodingKeys.deleted.rawValue, isEqualTo: false)
                .order(by: DBTransaction.CodingKeys.date.rawValue, descending: true)
                .limit(to: limit)
                .startOptionally(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: DBTransaction.self)
        } catch {
            print(error)
        }
        return ([], nil)
    }
    
    func deleteTransaction (transactionId: String) async throws {
        try await transactionCollection.document(transactionId).updateData(["deleted":true])
    }
    
    func getHotkeys() async throws -> [DBHotkey] {
        let (FBTransactions, _) = await getLastNTransactions(limit: 200)
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
