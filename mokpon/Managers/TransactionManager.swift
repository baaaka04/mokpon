import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


@MainActor
final class TransactionManager {
    
    static let shared = TransactionManager()
    
    var rates : Rates? = nil
    
    private init () {
        Task {
            self.rates = await APIService.shared.fetchCurrencyRates()
        }
    }

    private let transactionCollection = Firestore.firestore().collection("transactions") //if there's no collection in db, it will be created
    private func transactionDocument(transactionId: String) -> DocumentReference {
        transactionCollection.document(transactionId)
    }
    
    //use a dictionary instead of a struct because we need Document ID generated on Firebase
    func createNewTransaction(categoryId: String, subcategory: String, type: ExpensesType, date: Date, sum: Int, currencyId: String, userId: String) async throws {
        let negativeSum : Int = -sum
        let documentRef = try await transactionCollection.addDocument(data: [
            "category_id" : categoryId,
            "subcategory" : subcategory.lowercased(),
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
        
    func getLastNTransactions(limit: Int, lastDocument: DocumentSnapshot? = nil ) async throws -> (documents: [DBTransaction], lastDocument: DocumentSnapshot?) {
        return try await transactionCollection
            .whereField(DBTransaction.CodingKeys.deleted.rawValue, isEqualTo: false)
            .order(by: DBTransaction.CodingKeys.date.rawValue, descending: true)
            .limit(to: limit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: DBTransaction.self)
    }
    
    func deleteTransaction (transactionId: String) async throws {
        try await transactionCollection.document(transactionId).updateData(["deleted":true])
    }
    
    func getHotkeys() async throws -> [DBHotkey] {
        let (FBTransactions, _) = try await getLastNTransactions(limit: 200)
           return Dictionary(grouping: FBTransactions, by: {DBHotkey(categoryId: $0.categoryId, subcategory: $0.subcategory, count: 0)})
                .map { (key, arr) in DBHotkey(categoryId: key.categoryId, subcategory: key.subcategory, count: arr.count) }
                .sorted { $0.count > $1.count }
    }
    
    func convertCurrency (value: Int, from: String?, to: String?) -> Int? {
        
        guard let rates, let from, let to else {return nil}
        let rateInd : [String : Double] = [
            "USDRUB" : rates.RUB,
            "USDKGS" : rates.KGS,
            "RUBUSD" : 1 / rates.RUB,
            "RUBKGS" : rates.KGS / rates.RUB,
            "KGSUSD" : 1 / rates.KGS,
            "KGSRUB" : rates.RUB / rates.KGS,
            "RUBRUB" : 1,
            "USDUSD" : 1,
            "KGSKGS" : 1
        ]
        
        return Int( Double(value) * (rateInd[from+to] ?? 0) )
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
