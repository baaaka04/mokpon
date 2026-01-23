import Foundation
import FirebaseFirestore

struct Amount: Codable {
    let curId: String
    let sum: Int
}

struct UserAmounts: Codable {
    let userId: String
    let dateUpdated: Date
    let amounts: [Amount]
}

final class TransactionManager {

    init() {print("\(Date()): INIT TransactionManager")}
    deinit {print("\(Date()): DEINIT TransactionManager")}

    /// if there's no collection in db, it will create it
    private let transactionCollection = Firestore.firestore().collection("transactions")
    private let amountsCollection = Firestore.firestore().collection("amounts")

    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    func getLastNTransactions(limit: Int, userId: String, lastDocument: DocumentSnapshot? = nil, searchText: String = "", selectedCategoryId: String? = nil) async -> (documents: [DBTransaction], lastDocument: DocumentSnapshot?) {
        do {
            var query = transactionCollection
                .whereField(DBTransaction.CodingKeys.userId.rawValue, isEqualTo: userId)
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

    private func performTransactionWithAmountUpdate(
        transaction: Transaction,
        userId: String,
        sumDelta: Int,
        transactionRef: DocumentReference,
        writeOperation: @escaping (_ firestoreTxn: inout FirebaseFirestore.Transaction, _ txRef: DocumentReference) throws -> Void
    ) async throws -> String {
        let database = Firestore.firestore()
        let amountsRef = self.amountsCollection.document(userId)

        let result = try await database.runTransaction { (firestoreTxn, errorPointer) -> Any? in
            do {
                // 1. Get current amounts
                let snapshot = try firestoreTxn.getDocument(amountsRef)
                guard let data = snapshot.data(),
                      let userAmounts = try? self.decoder.decode(UserAmounts.self, from: data) else {
                    errorPointer?.pointee = NSError(
                        domain: "TransactionManager",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to decode user amounts"]
                    )
                    return nil
                }

                // 2. Update amounts for the certain currency
                let updatedAmounts = userAmounts.amounts.map { amount in
                    if amount.curId == transaction.currency.id {
                        return Amount(curId: amount.curId, sum: amount.sum + sumDelta)
                    }
                    return amount
                }

                let newUserAmounts = UserAmounts(userId: userId, dateUpdated: Date(), amounts: updatedAmounts)
                guard let encoded = try? self.encoder.encode(newUserAmounts) else {
                    errorPointer?.pointee = NSError(
                        domain: "TransactionManager",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to encode user amounts"]
                    )
                    return nil
                }

                // 3. Run custom operation (create/update/delete)
                var mutableTxn = firestoreTxn
                try writeOperation(&mutableTxn, transactionRef)

                // 4. Save updated amounts
                mutableTxn.setData(encoded, forDocument: amountsRef)

                return transactionRef.documentID
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }

        guard let generatedId = result as? String else {
            throw AppError.noDataToPresent
        }

        return generatedId
    }


    func createTransactionWithAmountUpdate(transaction: Transaction, userId: String) async throws -> String {
        let txRef = self.transactionCollection.document()

        let FBTransactionID = try await performTransactionWithAmountUpdate(
            transaction: transaction,
            userId: userId,
            sumDelta: transaction.sum,
            transactionRef: txRef
        ) { txn, txRef in
            // Using dictionary instead of a struct because we need Document ID generated on Firebase
            let transactionData: [String: Any] = [
                "id": txRef.documentID,
                "category_id": transaction.category.id,
                "subcategory": transaction.subcategory.lowercased(),
                "type": transaction.type.rawValue,
                "date": transaction.date,
                "sum": transaction.sum,
                "currency_id": transaction.currency.id,
                "deleted": false,
                "user_id": userId
            ]
            txn.setData(transactionData, forDocument: txRef)
        }
        return FBTransactionID
    }

    func deleteTransactionWithAmountUpdate(transaction: Transaction, userId: String) async throws {
        let txRef = self.transactionCollection.document(transaction.id)

        _ = try await performTransactionWithAmountUpdate(
            transaction: transaction,
            userId: userId,
            sumDelta: -transaction.sum,
            transactionRef: txRef
        ) { txn, txRef in
            txn.updateData(["deleted": true], forDocument: txRef)
        }
    }


    func getUserAmounts(userId: String) async throws -> [Amount] {
        try await amountsCollection.document(userId).getDocument().data(as:UserAmounts.self, decoder: decoder).amounts
    }

    func createAmounts(userId: String, currencies: [Currency]) async throws {
        let newAmounts = currencies.map { currency in
            ["cur_id" : currency.id, "sum" : 0]
        }
        try await amountsCollection.document(userId).setData([
            "amounts" : newAmounts,
            "date_updated" : Date(),
            "user_id" : userId
        ])
    }

}
