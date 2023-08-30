import Foundation
import SwiftUI

enum ExpensesType : String, Codable {
    case income = "доход"
    case expense = "опер"
    case invest = "инвест"
}

struct Transaction {
    let id : String
    let category : Category?
    let subcategory : String
    let date : Date
    let sum : Int
    let currency : Currency?
    let type : ExpensesType
    
    init(DBTransaction: DBTransaction) {
        self.id = DBTransaction.id
        self.subcategory = DBTransaction.subcategory
        self.date = DBTransaction.date
        self.sum = DBTransaction.sum
        
        let category = DirectoriesManager.shared.getCategory(byID: DBTransaction.categoryId)
        let currency = DirectoriesManager.shared.getCurrency(byID: DBTransaction.currencyId)
        
        self.category = category
        self.currency = currency
        self.type = DBTransaction.type
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
