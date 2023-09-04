import Foundation
import SwiftUI

enum ExpensesType : String, Codable {
    case income = "доход"
    case expense = "опер"
    case invest = "инвест"
}

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


// CurrencyModel ----------------
struct Rates: Codable {
    let KGS : Double
    let RUB : Double
}
struct Rate : Decodable {
    let bid : String
}
struct DTOcur : Decodable {
    let USDKGS : Rate
    let USDRUB : Rate
}
// CurrencyModel ----------------
