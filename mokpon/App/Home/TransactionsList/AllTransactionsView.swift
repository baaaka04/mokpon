import SwiftUI

struct AllTransactionsView: View {

    let transactions: [Transaction]?
    let getTransactions: @MainActor() -> ()
    let updateTransactions: @MainActor() -> ()
    let deleteTransaction: @MainActor(_ transaction: Transaction) -> ()
    let updateUserAmounts: (_ curId: String, _ sumDiff : Int) async throws -> ()
    @Binding var showView: Bool

    let convertCurrency : (_ value: Int, _ from: String?, _ to: String?) -> Int?
    let directoriesManager: DirectoriesManager

    // Searching
    @Binding var searchText: String
    @Binding var selectedScope: Category?
    var searchScopes: [Category]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bg_main
                VStack {
                    CategorySelector(
                        searchText: $searchText,
                        selectedScope: $selectedScope,
                        searchScopes: searchScopes,
                        updateTransactions: updateTransactions
                    )
                    TransactionListView(
                        transactions: transactions,
                        getTransactions: getTransactions,
                        updateTransactions: updateTransactions,
                        deleteTransaction: deleteTransaction,
                        updateUserAmounts: updateUserAmounts,
                        convertCurrency: convertCurrency,
                        directoriesManager: directoriesManager
                    )
                    .toolbar {
                        ToolbarItem (placement: .cancellationAction) {
                            Button("Close") {
                                onDissmiss()
                            }.foregroundColor(Color.accentColor)
                        }
                        ToolbarItem (placement: .principal) {
                            Text("All transactions")
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(Color(#colorLiteral(red: 0.1137254902, green: 0.1098039216, blue: 0.2235294118, alpha: 1)), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .searchable(text: $searchText, placement: .automatic)
                }
                .padding()
                .foregroundColor(.init(white: 0.87))
                .background(Color.bg_transactions)
            }
        }
        .onDisappear {
            onDissmiss()
        }
    }

    private func onDissmiss() {
        selectedScope = nil
        searchText = ""
        showView = false
    }
}

struct AllTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        AllTransactionsView(
            transactions: [],
            getTransactions: {},
            updateTransactions: {},
            deleteTransaction: {a in },
            updateUserAmounts: { curId, sumDiff in  },
            showView: .constant(true),
            convertCurrency: {a, b, c in return 0},
            directoriesManager: DirectoriesManager(),
            searchText: .constant(""),
            selectedScope: .constant(Category(id: "", name: "", icon: "", type: .expense)),
            searchScopes: []
        )
    }
}
