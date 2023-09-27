import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


final class ChartsManager {
    
    init() {print("\(Date()): INIT ChartsManager")}
    deinit {print("\(Date()): DEINIT ChartsManager")}
    
    private let transactionsCollection = Firestore.firestore().collection("transactions")
    
    private func getPeriod (year: Int, month: Int) throws -> (startTimestamp: Date, endTimestamp : Date) {
        guard 1...12 ~= month else { throw URLError(.badURL) }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let startDate = formatter.date(from: "\(year)/\(month)/01 00:00")!
        let endDate = startDate.endOfMonth
        
        return (startDate, endDate)
    }
    
    private func getTransactionsQuery (year: Int, month: Int) throws -> Query {
        let (startDate, endDate) = try getPeriod(year: year, month: month)
        return transactionsCollection
            .whereField(DBTransaction.CodingKeys.deleted.rawValue, isEqualTo: false)
            .whereField(DBTransaction.CodingKeys.date.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(DBTransaction.CodingKeys.date.rawValue, isLessThanOrEqualTo: endDate)
    }
    private func getTransactionsOfCategoryQuery (year: Int, month: Int, categoryId: String) throws -> Query {
        return try getTransactionsQuery(year: year, month: month)
            .whereField(DBTransaction.CodingKeys.categoryId.rawValue, isEqualTo: categoryId)
    }
    
    func getTransactions(year: Int, month: Int, categoryId: String? = nil) async throws -> [DBTransaction] {
        var query : Query = try getTransactionsQuery(year: year, month: month)
        if let categoryId {
            query = try getTransactionsOfCategoryQuery(year: year, month: month, categoryId: categoryId)
        }
        return try await query
            .getDocuments(as: DBTransaction.self)
    }
    
}
