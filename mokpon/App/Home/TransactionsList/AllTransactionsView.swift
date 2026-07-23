import SwiftUI

struct AllTransactionsView: View {

    let transactions: [Transaction]
    let getTransactions: @MainActor() -> ()
    let deleteTransaction: (_ transaction: Transaction) async throws -> ()
    let convertCurrency : (_ value: Int, _ from: String?, _ to: String?) -> Int?
    let directoriesManager: DirectoriesManager

    // Searching
    @Binding var searchText: String
    @Binding var selectedScope: Category?
    var searchScopes: [Category]

    var body: some View {
        NavigationView {
            ZStack {
                TransactionListView(
                    transactions: transactions,
                    deleteTransaction: deleteTransaction,
                    convertCurrency: convertCurrency,
                    directoriesManager: directoriesManager,
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
            getTransactions()
        }
        .onDisappear {
            selectedScope = nil
            searchText = ""
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
            directoriesManager: DirectoriesManager(),
            searchText: .constant(""),
            selectedScope: .constant(Category(id: "", name: "", icon: "", type: .expense)),
            searchScopes: []
        )
    }
}
