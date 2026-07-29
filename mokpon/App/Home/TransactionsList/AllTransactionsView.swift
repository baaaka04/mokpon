import SwiftUI

struct AllTransactionsView: View {

    let transactions: [Transaction]
    let getTransactions: @MainActor() -> ()
    let deleteTransaction: (_ transaction: Transaction) async throws -> ()
    let convertCurrency : (_ value: Int, _ from: String?, _ to: String?) -> Int?

    // Searching
    @Binding var searchText: String
    @Binding var selectedScope: CategoryEnum?
    var searchScopes: [CategoryEnum]

    var body: some View {
        NavigationView {
            ZStack {
                TransactionListView(
                    transactions: transactions,
                    deleteTransaction: deleteTransaction,
                    convertCurrency: convertCurrency,
                    loadMore: getTransactions
                )
                .padding(.vertical)
                .ignoresSafeArea()
            }
            .foregroundColor(.init(white: 0.87))
            .background(Color.bg_transactions)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("All transactions")
            .searchable(text: $searchText, placement: .automatic)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                CategorySelector(
                    selectedScope: $selectedScope,
                    searchScopes: searchScopes,
                )
            }
        }
        .onAppear {
            if selectedScope != nil {
                selectedScope = nil
            }
            if !searchText.isEmpty {
                searchText = ""
            }
        }
    }
}

struct AllTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        AllTransactionsView(
            transactions: [],
            getTransactions: {},
            deleteTransaction: {a in },
            convertCurrency: {a, b, c in return 0},
            searchText: .constant(""),
            selectedScope: .constant(.cat01),
            searchScopes: []
        )
    }
}
