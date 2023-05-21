import Foundation

struct OperationKey : Identifiable {
    let id = UUID()
    let action : String
    let iconName : String
}

let operationKeys : [OperationKey] = [
    .init(action: "+", iconName: "plus"),
    .init(action: "-", iconName: "minus"),
    .init(action: "/", iconName: "divide"),
    .init(action: "*", iconName: "multiply"),
    .init(action: "=", iconName: "equal"),
]
