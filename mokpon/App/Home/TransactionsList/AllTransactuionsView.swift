import SwiftUI

struct AllTransactuionsView: View {
    
    let transactions : [Transaction]
    let fetchTransactions : () -> Void
    var isLoading : Bool
    @Binding var showView : Bool
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: nil, alignment: .leading),
        GridItem(.flexible(), spacing: nil, alignment: .center),
        GridItem(.flexible(), spacing: nil, alignment: .trailing),
    ]

    var body: some View {
        ZStack {
            Color.bg_main
            VStack {
                LazyVGrid (columns: columns) {
                    
                    Button("Cancel") {
                        showView = false
                    }
                    .font(.custom("DMSans-Regular", size: 16))
                    Text("All Transactions")
                        .font(.custom("DMSans-Regular", size: 20))
                        .frame(width: 160)
                        .foregroundColor(.white)
                    Image(systemName: "magnifyingglass")
                }
                .foregroundColor(Color.accentColor)
                
                TransactionListView(
                    transactions: transactions,
                    fetchTransactions: fetchTransactions,
                    isLoading: isLoading
                )
            }
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
        ], fetchTransactions: HomeViewModel().fetchTransactions, isLoading: false, showView: .constant(true))
    }
}
