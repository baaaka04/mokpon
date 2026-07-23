import Foundation
import SwiftUI


@MainActor
final class NewTransactionViewModel: ObservableObject {

    @Published var sum: Int = 0
    @Published var subCategory = ""
    @Published var category: CategoryEnum? = nil
    @Published var type: ExpensesType = .expense
    @Published var currency: Currency = .rub

    //CALCULATOR
    @Published var memo: Int = 0
    @Published var prevKey: String = "="
    @Published var needToErase = false

    init() {print("\(Date()): INIT NewTransactionViewModel")}
    deinit {print("\(Date()): DEINIT NewTransactionViewModel")}

    func onPressHotkey(category: CategoryEnum, subcategory: String) -> Void {
        self.category = category
        self.subCategory = subcategory
        self.type = category.type
    }

    func validate() throws {
        guard self.sum != 0 && self.category != nil && !self.subCategory.isEmpty else {
            throw AppError.epmtyFields
        }
    }
}

//Calculator buttons
extension NewTransactionViewModel {
    func onPressDigit(number: String) -> Void {
        self.needToErase ? self.sum = 0 : nil
        let prevNumber = self.sum
        let newNumber = String(prevNumber) + number
        self.sum = Int(newNumber) ?? prevNumber
        self.needToErase = false
    }
    
    func onPressClear(btn: String) -> Void {
        self.sum = 0
        self.memo = 0
        self.prevKey = ""
    }
    
    func onPressBackspace(btn: String) -> Void {
        let str = String(sum)
        self.sum = str.count > 1 ? Int(str.dropLast())! : 0
    }
    
    func calcualte(key: String) -> Void {
        
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
