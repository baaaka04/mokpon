import Foundation

enum ChartType: String, CaseIterable {
    case pie, bar
}
enum Comparation: String, CaseIterable {
    case fiveMonth = "5-month"
    case monthly = "Month"
    case yearly = "Year"
}
struct ChartData: Identifiable {
    let id: String
    let category: Category
    let currency: Currency
    let sum: Int
    let month: Int
    let year: Int
    let percentDiff: Int?
    
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

struct ChartsDate: Hashable, Equatable {

    struct ChartPeriod: Hashable, Equatable {
        var year, month: Int
    }
    var currentPeriod: ChartPeriod
    
    init(month: Int, year: Int) {
        self.currentPeriod = ChartPeriod(year: year, month: month)
    }

    init(date: Date) {
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        self.currentPeriod = ChartPeriod(year: year, month: month)
    }

    var previousMonthPeriod: ChartPeriod {
        let month = decreaseMonth(period: currentPeriod).month
        let year = decreaseMonth(period: currentPeriod).year
        
        return ChartPeriod(year: year, month: month)
    }
    var previousYearPeriod: ChartPeriod {
        return ChartPeriod(year: currentPeriod.year-1, month: currentPeriod.month)
    }
    
    mutating func decreaseMonth() -> Void {
        self.currentPeriod = decreaseMonth(period: currentPeriod)
    }
    
    mutating func increaseMonth() -> Void {
        if self.currentPeriod.month == 12 {
            self.currentPeriod.month = 1
            self.currentPeriod.year += 1
        } else {
            self.currentPeriod.month += 1
        }
    }
        
    private func decreaseMonth(period: ChartPeriod) -> ChartPeriod {
        var resultPeriod = ChartPeriod(year: period.year, month: period.month)
        
        if period.month == 1 {
            resultPeriod.month = 12
            resultPeriod.year -= 1
        } else {
            resultPeriod.month -= 1
        }
        return resultPeriod
    }

    
}

// charts data in rows below
struct ExpenseData {
    let title: String
    let subtitle: String
    let number: String
    let category: Category
}

func getChartMonthName(year: Int, month: Int) -> String {
    var components = DateComponents()
    components.month = month
    components.year = year

    let calendar = Calendar.current
    if let date = calendar.date(from: components) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM''yy"
        return dateFormatter.string(from: date)
    }
    return "Invalid date"
}
