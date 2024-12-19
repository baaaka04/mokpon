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
    
    private let transactionManager: TransactionManager
    private let directoriesManager: DirectoriesManager
    
    init(appContext: AppContext) {
        self.transactionManager = appContext.transactionManager
        self.directoriesManager = appContext.directoriesManager
        print("\(Date()): INIT NewTransactionViewModel")
    }
    deinit {print("\(Date()): DEINIT NewTransactionViewModel")}
    
    // GET Request from Firebase DB for hotkeys
    func getHotkeys() {
        Task {
            let DBHotkeys = try await transactionManager.getHotkeys()
            self.hotkeys = DBHotkeys
                .prefix(16)
                .compactMap {
                    if let category = directoriesManager.getCategory(byID: $0.categoryId) {
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
