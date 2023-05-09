import SwiftUI

struct AllTransactuionsView: View {
    
    let transactions : [Transaction]
    let fetchTransactions : () -> Void
    var isLoading : Bool

    var body: some View {
        ZStack {
            TransactionListView(
                transactions: transactions,
                fetchTransactions: fetchTransactions,
                isLoading: isLoading
            )
            .frame(height: 500)
            .padding()
            .foregroundColor(.init(white: 0.87))
            .background(Color.bg_transactions)
        }
    }
}

struct AllTransactuionsView_Previews: PreviewProvider {
    static var previews: some View {
        AllTransactuionsView(transactions: [
            Transaction(category: "food", subCategory: "healthy", type: .expense, date: Date(), sum: 200),
            Transaction(category: "food", subCategory: "healthy", type: .expense, date: Date(), sum: 200),
            Transaction(category: "transport", subCategory: "taxi", type: .expense, date: Date(), sum: 150)
        ], fetchTransactions: HomeViewModel().fetchTransactions, isLoading: false)
    }
}
