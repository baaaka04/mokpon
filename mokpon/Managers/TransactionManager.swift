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
    func createNewTransaction(categoryId: String, subcategory: String, type: ExpensesType.RawValue, date: Date, sum: Int, currencyId: String, userId: String) async throws {
        try await transactionCollection.addDocument(data: [
            "category_id" : categoryId,
            "subcategory" : subcategory,
            "type" : type,
            "date" : date,
            "sum" : sum,
            "currency_id" : currencyId,
            "deleted" : false,
            "userId" : userId
        ])
    }
}
