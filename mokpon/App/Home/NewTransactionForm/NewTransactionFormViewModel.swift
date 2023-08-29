import Foundation
import SwiftUI

@MainActor
final class NewTransactionViewModel : ObservableObject {
    @Published var sum : Int = 0
    @Published var subCategory = ""
    @Published var category: Category?
    @Published var type: ExpensesType = .expense
    @Published var currency : Currency? = nil
    @Published var currentCurrencyInd : Int = 0
    @Published var hotkeys : [[String]]? = nil
    
    //calculator
    @Published var memo : Int = 0
    @Published var prevKey : String = "="
    @Published var isCalcVisible : Bool = false
    @Published var needToErase = false
    
    // Firebase POST request
    func sendNewTransactionFirebase () async throws {
        let user = try AuthenticationManager.shared.getAuthenticatedUser()
        try await TransactionManager.shared.createNewTransaction(
            categoryId: category?.id ?? "n/a",
            subcategory: subCategory,
            type: type,
            date: Date(),
            sum: sum,
            currencyId: currency?.id ?? "n/a",
            userId: user.uid
        )
    }
    //    POST Request /newRow route
    func sendNewTransaction () async -> Void {
        await APIService.shared.sendNewTransaction(categoryName: category?.name, subcategoryName: subCategory, type: type, date: Date(), sum: sum)
    }
    
    func fetchHotkeys() async -> Void {
        let fetchedData = try? await APIService.shared.fetchHotkeys()
        self.hotkeys = fetchedData
    }
        
    func onPressHotkey (category: Category, subcategory: String) -> Void {
        self.category = category
        self.subCategory = subcategory
        self.type = category.type
    }
    
    func onPressDigit(number : String) -> Void {
        self.needToErase ? self.sum = 0 : nil
        let prevNumber = self.sum
        let newNumber = String(prevNumber) + number
        self.sum = Int(newNumber) ?? prevNumber
        self.needToErase = false
    }
    
    func onPressClear (btn : String) -> Void {
        self.sum = 0
        self.memo = 0
        self.prevKey = ""
    }
    
    func onPressBackspace (btn : String) -> Void {
        let str = String(sum)
        self.sum = str.count > 1 ? Int(str.dropLast())! : 0
    }
    
    func calcualte (key : String) -> Void {
        
        var calculated = 0
        switch prevKey {
        case "+":
            calculated = memo + sum
            self.memo = calculated
            self.sum = calculated
        case "-":
            calculated = memo - sum
            self.memo = calculated
            self.sum = calculated
        case "/":
            if self.sum != 0 {
                calculated = memo / sum
                self.memo = calculated
                self.sum = calculated
            }
        case "*":
            calculated = memo * sum
            self.memo = calculated
            self.sum = calculated
        default:
            self.memo = sum
        }
        self.prevKey = key // set last action as current for calculations
        self.needToErase = true //clear input for a new number after pushing OperationButton
        
    }
        
}
