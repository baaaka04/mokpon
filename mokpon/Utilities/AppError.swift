import Foundation

enum AppError: Error {
    case noNeedToExecute

    var description: String {
        switch self {
        case .noNeedToExecute:
            "There are reasons not to execute the code that follows."
        }
    }
}
