import Foundation

// charts types
enum ChartSelected {
    case bar, pie
}
enum Comparation {
    case monthly, yearly
}
// API communication
struct APIChartsResponse : Decodable{
    let barChartDatalist : ComparationList
    let barChartData : ComparationChart
}
struct ComparationChart : Decodable {
    let monthly : [BarChartData]
    let yearly : [BarChartData]
}
struct ComparationList : Decodable {
    let monthly : [BarChartDatalist]
    let yearly : [BarChartDatalist]
}
struct BarChartData : Decodable, Identifiable {
    let id = UUID()
    let category : String
    let sum : Int
    let date : String
}
struct BarChartDatalist : Decodable, Identifiable {
    let id = UUID()
    let category : String
    let prevSum : Int
    let curSum : Int
}
struct DTScharts : Encodable {
    let month: String
    let year: String
}

struct ChartsDate {
    var month : Int
    var year : Int
    
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



