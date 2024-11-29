import Foundation
import SwiftUI

struct Transaction : Equatable {
    let id : String
    let category : Category
    let subcategory : String
    let date : Date
    let sum : Int
    let currency : Currency
    let type : ExpensesType
    
    init(DBTransaction: DBTransaction, category: Category, currency: Currency) {
        self.id = DBTransaction.id
        self.subcategory = DBTransaction.subcategory
        self.date = DBTransaction.date
        self.sum = DBTransaction.sum
        self.type = DBTransaction.type
        
        self.category = category
        self.currency = currency
    }
    
    static func ==(lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.id == rhs.id
    }
}
enum ExpensesType : String, Codable {
    case income = "доход"
    case expense = "опер"
    case invest = "инвест"
    case exchange
}
struct Category : Codable, Identifiable, Hashable {
    let id : String
    let name : String
    let icon : String
    let type : ExpensesType
}

struct Currency : Codable, Identifiable, Hashable {
    let id : String
    let name : String
    let symbol : String
}
struct Hotkey {
    let category : Category
    let subcategory : String
}

// CurrencyModel ----------------
struct Rates: Codable {
    let RUBKGS : Double
    let USDKGS : Double
    let EURKGS : Double
}
struct Rate : Decodable {
    let bid : String
}
struct DTOcur : Decodable {
        let id: Int
        let created_at: String
        let updated_at: String
        let is_current: Int
        let usd: String
        let eur: String
        let rub: String
}
// CurrencyModel ----------------
