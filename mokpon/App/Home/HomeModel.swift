import Foundation
import SwiftUI

enum ExpensesType {
    case income, expense, invest
}
enum Currency {
    case RUB, KGS
}

struct Transaction : Hashable, Decodable {
    let id = UUID()
    let category : String
    let subCategory : String
    let type : String
    let date : Date
    let sum : Int
    
    init(category: String, subCategory: String, type: ExpensesType, date: Date, sum: Int) {
        self.category = category
        self.subCategory = subCategory
        
        switch type {
        case .expense: self.type = "опер"
        case .income: self.type = "доход"
        case .invest: self.type = "инвест"
        }
        
        self.date = date
        self.sum = sum
    }
}
struct TransactionToJSON : Encodable{
    let category : String
    let subCategory : String
    let opex : String
    let date : String
    let sum : String
}
let categories : [String: String] = [
    "питание": "cart",
    "транспорт": "bus.fill",
    "здоровье": "cross",
    "ЖКХ": "house",
    "одежда": "tshirt",
    "развлечения": "party.popper",
    "подарки": "gift",
    "бытовуха": "stove",
    "интернет и связь": "wifi",
    "прочее": "questionmark",
    "животные": "pawprint.fill",
    "доход": "dollarsign"
]

// CurrencyModel ----------------
struct Rates: Decodable, Encodable {
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
