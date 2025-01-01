import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


final class ChartsManager {
    
    init() {print("\(Date()): INIT ChartsManager")}
    deinit {print("\(Date()): DEINIT ChartsManager")}
    
    private let transactionsCollection = Firestore.firestore().collection("transactions")
    
    private func getQueryPeriod(year: Int, month: Int, forMonths: Int = 1) throws -> (startTimestamp: Date, endTimestamp : Date) {
        guard 1...12 ~= month, 1...5 ~= forMonths else { throw URLError(.badURL) }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let initialMonth = formatter.date(from: "\(year)/\(month)/01 00:00")!
        let calcMonth = month - forMonths
        let startYear = calcMonth < 0 ? year - 1 : year
        let startMonth = (calcMonth % 12 + 12) % 12 + 1
        let startDate = formatter.date(from: "\(startYear)/\(startMonth)/01 00:00")!
        let endDate = initialMonth.endOfMonth

        return (startDate, endDate)
    }
    
    private func getTransactionsQuery(year: Int, month: Int, forMonths: Int = 1) throws -> Query {
        let (startDate, endDate) = try getQueryPeriod(year: year, month: month, forMonths: forMonths)
        return transactionsCollection
            .whereField(DBTransaction.CodingKeys.deleted.rawValue, isEqualTo: false)
            .whereField(DBTransaction.CodingKeys.date.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(DBTransaction.CodingKeys.date.rawValue, isLessThanOrEqualTo: endDate)
    }
    private func getTransactionsOfCategoryQuery(year: Int, month: Int, categoryId: String) throws -> Query {
        return try getTransactionsQuery(year: year, month: month)
            .whereField(DBTransaction.CodingKeys.categoryId.rawValue, isEqualTo: categoryId)
    }
    
    func getTransactions(year: Int, month: Int, categoryId: String? = nil, forMonths: Int = 1) async throws -> [DBTransaction] {
        var query : Query = try getTransactionsQuery(year: year, month: month, forMonths: forMonths)
        if let categoryId {
            query = try getTransactionsOfCategoryQuery(year: year, month: month, categoryId: categoryId)
        }
        return try await query
            .getDocuments(as: DBTransaction.self)
    }
    
}
