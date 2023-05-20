import Foundation


class NewTransactionViewModel : ObservableObject {
    @Published var sum : Int = 0
    @Published var subCategory = ""
    @Published var category: String?
    @Published var type: ExpensesType = .expense
    
    //calculator
    @Published var memo : Int = 0
    @Published var prevKey : String = "="
    @Published var isCalcVisible : Bool = false
    @Published var needToErase = false
    //calculator
    
    @Published var hotkeys : [[String]] = [[]]
    
    func fetchHotkeys() async -> Void {
        let fetchedData = await APIService.shared.fetchHotkeys()
        await MainActor.run {
            self.hotkeys = fetchedData
        }
    }
        
    func onPressHotkey (hotkey: [String]) -> Void {
        self.category = hotkey[0]
        self.subCategory = hotkey[1]
        switch hotkey[2] {
        case "доход":
            self.type = .income
        case "инвест":
            self.type = .invest
        default:
            self.type = .expense
        }
    }
    
    func onPressDigit(number : String) -> Void {
        self.needToErase ? self.sum = 0 : nil
        self.sum = Int(String(self.sum)+number)! //написать функцию проверки длинны
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
