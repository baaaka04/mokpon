import Foundation
import SwiftUI

struct Hotkey {
    let category : Category
    let subcategory : String
    
    init(categoryId: String, subcategory: String) {
        self.category = DirectoriesManager.shared.getCategory(byID: categoryId)
        self.subcategory = subcategory
    }
}

@MainActor
final class NewTransactionViewModel : ObservableObject {
    @Published var sum : Int = 0
    @Published var subCategory = ""
    @Published var category: Category?
    @Published var type: ExpensesType = .expense
    @Published var currency : Currency? = nil
    @Published var currentCurrencyInd : Int = 0
    @Published var hotkeys : [Hotkey]? = nil
    
    //calculator
    @Published var memo : Int = 0
    @Published var prevKey : String = "="
    @Published var isCalcVisible : Bool = false
    @Published var needToErase = false
    
    // Firebase POST request
    func sendNewTransactionFirebase () async throws {
        let user = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let currencyId = currency?.id else {return}
        try await TransactionManager.shared.createNewTransaction(
            categoryId: category?.id ?? "n/a",
            subcategory: subCategory,
            type: type,
            date: Date(),
            sum: sum,
            currencyId: currencyId,
            userId: user.uid
        )
    }
    
    func updateUserAmounts () async throws {
        let user = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let currency else {return}
        try await AmountManager.shared.updateUserAmounts(userId: user.uid, curId: currency.id, sumDiff: type == .income ? sum : -sum)
    }
    
    //    POST Request /newRow route
    func sendNewTransaction () async -> Void {
        await APIService.shared.sendNewTransaction(categoryName: category?.name, subcategoryName: subCategory, type: type, date: Date(), sum: sum)
    }
    // GET Request from Firebase DB for hotkeys
    func getHotkeys() {
        Task {
            let DBHotkeys = try await TransactionManager.shared.getHotkeys()
            self.hotkeys = DBHotkeys.prefix(8)
                .map {Hotkey(categoryId: $0.categoryId, subcategory: $0.subcategory)}
        }
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
