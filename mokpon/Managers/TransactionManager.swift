import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


@MainActor
final class TransactionManager {
    
    static let shared = TransactionManager()
    
    private init () {}

    private let transactionCollection = Firestore.firestore().collection("transactions") //if there's no collection in db, it will be created
    private func transactionDocument(transactionId: String) -> DocumentReference {
        transactionCollection.document(transactionId)
    }
    
    //use dictionary instead struct because we need Document ID generated on Firebase
    func createNewTransaction(categoryId: String, subcategory: String, type: ExpensesType, date: Date, sum: Int, currencyId: String, userId: String) async throws {
        let negativeSum : Int = -sum
        let documentRef = try await transactionCollection.addDocument(data: [
            "category_id" : categoryId,
            "subcategory" : subcategory,
            "type" : type.rawValue,
            "date" : date,
            "sum" : type == .income ? sum: negativeSum,
            "currency_id" : currencyId,
            "deleted" : false,
            "user_id" : userId
        ])
        let documentId = documentRef.documentID
        try await transactionCollection.document(documentId).updateData(["id":documentId])
    }
    
    func getLastNTransactions(limit: Int ) async throws -> [DBTransaction] {
        try await transactionCollection
            .order(by: DBTransaction.CodingKeys.date.rawValue, descending: true)
            .limit(toLast: limit)
            .getDocuments(as: DBTransaction.self)
    }
}

struct DBTransaction : Decodable {
    let id : String
    let categoryId : String
    let subcategory : String
    let type : ExpensesType
    let date : Date
    let sum : Int
    let currencyId : String
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
