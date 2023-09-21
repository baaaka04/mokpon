import Foundation

enum ChartType {
    case bar, pie
}
enum Comparation {
    case monthly, yearly
}
struct ChartData : Identifiable {
    let id : String
    let category : Category
    let currency : Currency
    let sum : Int
    let month : Int
    let year : Int
    let percentDiff : Int?
    
    init(category: Category, currency: Currency, sum: Int, month: Int, year: Int, percentDiff: Int? = nil) {
        self.category = category
        self.currency = currency
        self.sum = sum
        self.month = month
        self.year = year
        self.id = "\(month)-\(year)-\(category.id)"
        self.percentDiff = percentDiff
    }
}
struct ChartsDate {
    var month : Int
    var year : Int
    var prevYear : Int {
        return year - 1
    }
    var prevMonth : Int {
        let prevMonth = self.month-1
        return 1...12 ~= prevMonth ? prevMonth : 12
    }
    
    mutating func increaseMonth () -> Void {
        if self.month == 12 {
            self.month = 1
            self.year += 1
        } else {
            self.month += 1
        }
    }
    mutating func decreaseMonth () -> Void {
        if self.month == 1 {
            self.month = 12
            self.year -= 1
        } else {
            self.month -= 1
        }
    }
}
// charts data in rows below
struct ExpenseData {
    let title : String
    let subtitle : String
    let number : String
    let category : Category
}

func getChartMonthName (year: Int, month: Int) -> String {
    return "\(DateFormatter().monthSymbols[month-1].capitalized)'\(String(String(year).dropFirst(2)))"
}

