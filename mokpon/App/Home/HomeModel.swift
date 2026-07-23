import Foundation
import SwiftUI

struct Transaction: Equatable {
    var id: String
    let category: CategoryEnum
    let subcategory: String
    let date: Date
    let sum: Int
    let currency: Currency
    let type: ExpensesType

    init(id: String, category: CategoryEnum, subcategory: String, date: Date, sum: Int, currency: Currency, type: ExpensesType) {
        self.id = id
        self.category = category
        self.subcategory = subcategory
        self.date = date
        self.sum = sum
        self.currency = currency
        self.type = type
    }

    init(DBTransaction: DBTransaction, category: CategoryEnum, currency: Currency) {
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

enum ExpensesType: String, Codable {
    case income = "доход"
    case expense = "опер"
    case invest = "инвест"
    case exchange
}

enum Currency: String, Codable, Hashable, Identifiable, CaseIterable {
    case usd = "cur-01"
    case rub = "cur-02"
    case kgs = "cur-03"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .usd: return "USD"
        case .rub: return "RUB"
        case .kgs: return "KGS"
        }
    }
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .rub: return "₽"
        case .kgs: return "c"
        }
    }
    
    var next: Currency {
        let all = Currency.allCases
        let idx = all.firstIndex(of: self)!
        return all[(idx + 1) % all.count]
    }
    
}

enum CategoryEnum: String, CaseIterable, Identifiable {
    case cat01, cat02, cat03, cat04, cat05, cat06, cat07, cat08, cat09, cat10, cat11, cat12, cat13, cat14
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .cat01: return "питание"
        case .cat02: return "транспорт"
        case .cat03: return "здоровье"
        case .cat04: return "ЖКХ"
        case .cat05: return "одежда"
        case .cat06: return "развлечения"
        case .cat07: return "подарки"
        case .cat08: return "бытовуха"
        case .cat09: return "интернет и связь"
        case .cat10: return "прочее"
        case .cat11: return "животные"
        case .cat12: return "доход"
        case .cat13: return "прочее"
        case .cat14: return "обмен"
        }
    }
    
    var icon: String {
        switch self {
        case .cat01: return "cart"
        case .cat02: return "bus.fill"
        case .cat03: return "cross"
        case .cat04: return "house"
        case .cat05: return "tshirt"
        case .cat06: return "party.popper"
        case .cat07: return "gift"
        case .cat08: return "stove"
        case .cat09: return "wifi"
        case .cat10: return "questionmark"
        case .cat11: return "pawprint.fill"
        case .cat12: return "dollarsign"
        case .cat13: return "i.circle"
        case .cat14: return "arrow.triangle.2.circlepath"
        }
    }
    
    var type: ExpensesType {
        switch self {
        case .cat01, .cat02, .cat03, .cat04, .cat05, .cat06, .cat07, .cat08, .cat09, .cat10, .cat11: return .expense
        case .cat12: return .income
        case .cat13: return .invest
        case .cat14: return .exchange
        }
    }
    
    var color: Color {
        let index = (Int(rawValue.suffix(2)) ?? 1) - 1
        return Color.palette[index]
    }
}

struct DBTransaction: Decodable {
    let id: String
    let categoryId: String
    let subcategory: String
    let type: ExpensesType
    let date: Date
    var sum: Int
    var currencyId: Currency
    let deleted: Bool
    let userId: String

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
        self.currencyId = try container.decode(Currency.self, forKey: .currencyId)
        self.deleted = try container.decode(Bool.self, forKey: .deleted)
        self.userId = try container.decode(String.self, forKey: .userId)
    }
}

struct Hotkey {
    let category: CategoryEnum
    let subcategory: String
}

struct DBHotkey: Hashable {
    let categoryId: String
    let subcategory: String
    let count: Int
}

// CurrencyModel ----------------
struct Rates: Codable {
    let RUBKGS: Double
    let USDKGS: Double
    let EURKGS: Double
    let dateUpdated: Date
}
struct Rate: Decodable {
    let bid: String
}
struct DTOcur: Decodable {
    let id: Int
    let created_at: String
    let updated_at: String
    let is_current: Int
    let usd: String
    let eur: String
    let rub: String
}
// CurrencyModel ----------------
