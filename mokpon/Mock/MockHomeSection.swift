import SwiftUI


class MockHomeViewModel: ObservableObject, TransactionSendable {
    var hotkeys: [Hotkey]?

    func sendNewTransaction(transaction: Transaction) async throws {

    }

}
