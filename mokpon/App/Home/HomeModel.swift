import Foundation
import SwiftUI

enum ExpensesType : String, Codable {
    case income = "доход"
    case expense = "опер"
    case invest = "инвест"
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
