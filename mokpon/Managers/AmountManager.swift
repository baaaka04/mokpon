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

final class AmountManager {
            
    init () {print("\(Date()): INIT AmountManager")}
    deinit { print("\(Date()): DEINIT AmountManager") }
    
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

    
    func updateUserAmounts(userId: String, curId: String, sumDiff: Int) async throws -> [Amount] {
        let lastAmounts = try await getUserAmounts(userId: userId)

        let newAmounts = lastAmounts.map { am in
            let newSum = am.curId == curId ? am.sum + sumDiff : am.sum
            return Amount(curId: am.curId, sum: newSum)
        }
        
        guard let encodedAmounts = try? encoder.encode(UserAmounts(userId: userId, dateUpdated: Date(), amounts: newAmounts)) else {
            throw URLError(.badURL)
        }
        try await amountsCollection.document(userId).setData(encodedAmounts)
        return try await amountsCollection.document(userId).getDocument().data(as:UserAmounts.self, decoder: decoder).amounts
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
