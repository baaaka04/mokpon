import Foundation
import SwiftUI



@MainActor
final class NewTransactionViewModel : ObservableObject {
    @Published var sum : Int = 0
    @Published var subCategory = ""
    @Published var category: Category? = nil
    @Published var type: ExpensesType = .expense
    @Published var currency : Currency? = nil
    @Published var currentCurrencyInd : Int = 0
    @Published var hotkeys : [Hotkey]? = nil
    
    //CALCULATOR
    @Published var memo : Int = 0
    @Published var prevKey : String = "="
    @Published var needToErase = false
    
    let isExchange : Bool
    
    init(isExchange: Bool) {
        self.isExchange = isExchange
    }
    
    // Firebase POST request
    func sendNewTransaction () async throws {
        let user = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let currencyId = currency?.id else {return}
        try await TransactionManager.shared.createNewTransaction(
            categoryId: category?.id ?? "n/a",
            subcategory: subCategory,
            type: type,
            date: Date(),
            sum: type == .income || isExchange ? sum : -sum,
            currencyId: currencyId,
            userId: user.uid
        )
        print("\(Date()): Transaction has been sent")
    }
    
    func updateUserAmounts () async throws {
        let user = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let currency else {return}
        try await AmountManager.shared.updateUserAmounts(userId: user.uid, curId: currency.id, sumDiff: type == .income || isExchange ? sum : -sum)
    }
    
    // GET Request from Firebase DB for hotkeys
    func getHotkeys() {
        Task {
            let DBHotkeys = try await TransactionManager.shared.getHotkeys()
            self.hotkeys = DBHotkeys
                .prefix(8)
                .compactMap {
                    if let category = DirectoriesManager.shared.getCategory(byID: $0.categoryId) {
                        return Hotkey(category: category, subcategory: $0.subcategory)
                    } else { return nil } //if couldn't find a category, then skip
                }
        }
    }
        
    func onPressHotkey (category: Category, subcategory: String) -> Void {
        self.category = category
        self.subCategory = subcategory
        self.type = category.type
    }
    
    @discardableResult
    func switchCurrency (currencies: [Currency]?) -> Int {
        guard let currencies,
              currencies.count != 0 else {return 0}
        
        let newValue = self.currentCurrencyInd + Int(1)
        let newIndex = newValue % currencies.count
        
        self.currency = currencies[newIndex]
        self.currentCurrencyInd = newIndex
        return newIndex
    }
}

//Calculator buttons
extension NewTransactionViewModel {
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
