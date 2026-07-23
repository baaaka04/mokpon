import Foundation
import SwiftUI

struct Transaction: Equatable {
    var id: String
    let category: Category
    let subcategory: String
    let date: Date
    let sum: Int
    let currency: Currency
    let type: ExpensesType

    init(id: String, category: Category, subcategory: String, date: Date, sum: Int, currency: Currency, type: ExpensesType) {
        self.id = id
        self.category = category
        self.subcategory = subcategory
        self.date = date
        self.sum = sum
        self.currency = currency
        self.type = type
    }

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

enum ExpensesType: String, Codable {
    case income = "доход"
    case expense = "опер"
    case invest = "инвест"
    case exchange
}

struct Category: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let type: ExpensesType

    var color: Color {
        let index = (Int(id.suffix(2)) ?? 1) - 1
        return Color.palette[index]
    }
    
    static let all: [Category] = [
        .init(id: "cat01", name: "питание", icon: "cart", type: .expense),
        .init(id: "cat02", name: "транспорт", icon: "bus.fill", type: .expense),
        .init(id: "cat03", name: "здоровье", icon: "cross", type: .expense),
        .init(id: "cat04", name: "ЖКХ", icon: "house", type: .expense),
        .init(id: "cat05", name: "одежда", icon: "tshirt", type: .expense),
        .init(id: "cat06", name: "развлечения", icon: "party.popper", type: .expense),
        .init(id: "cat07", name: "подарки", icon: "gift", type: .expense),
        .init(id: "cat08", name: "бытовуха", icon: "stove", type: .expense),
        .init(id: "cat09", name: "интернет и связь", icon: "wifi", type: .expense),
        .init(id: "cat10", name: "прочее", icon: "questionmark", type: .expense),
        .init(id: "cat11", name: "животные", icon: "pawprint.fill", type: .expense),
        .init(id: "cat12", name: "доход", icon: "dollarsign", type: .income),
        .init(id: "cat13", name: "прочее", icon: "i.circle", type: .invest),
        .init(id: "cat14", name: "обмен", icon: "arrow.triangle.2.circlepath", type: .exchange),
    ]
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
    let category: Category
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
