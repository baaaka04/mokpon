import Foundation


class SubcategoryViewModel : ObservableObject {
    
    @Published var categoryExpenses : [ChartDatalist] = [
        .init(category: "здоровая пища", prevSum: 0, curSum: 140),
        .init(category: "всячина", prevSum: 0, curSum: 70),
        .init(category: "кафе", prevSum: 0, curSum: 50),
    ]
    
    func getCategoryExpenses (category: String, monthYear : ChartsDate) async -> Void {
        let fetchedData = await APIService.shared.fetchCategoryExpenses(category: category, date: monthYear)
        await MainActor.run {
            self.categoryExpenses = fetchedData
        }
    }
    
}
