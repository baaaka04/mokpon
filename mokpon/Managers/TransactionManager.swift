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
    
    func deleteTransaction(transactionId: String) async throws {
        try await transactionCollection.document(transactionId).updateData(["deleted":true])
    }

}
