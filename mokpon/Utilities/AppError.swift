import Foundation

enum AppError: Error {
    case noNeedToExecute, noDataToPresent, currency, epmtyFields

    var description: String {
        switch self {
        case .noNeedToExecute:
            "There are reasons not to execute the code that follows."
        case .noDataToPresent:
            "No data to present."
        case .currency:
            "Currency errror."
        case .epmtyFields:
            "Please fill out all the fields."
        }
    }
}
