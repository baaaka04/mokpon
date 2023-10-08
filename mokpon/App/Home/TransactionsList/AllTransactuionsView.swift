import SwiftUI

struct AllTransactuionsView: View {
    
    let transactions : [Transaction]
    let getTransactions : @MainActor() -> ()
    let deleteTransaction : @MainActor(_ transactionId: String) -> ()
    let updateUserAmounts : (_ curId: String, _ sumDiff : Int) async throws -> ()
    @Binding var showView : Bool
    
    //searching
    let scopes : [String]
    @Binding var searchText : String
    @Binding var searchScope : String
    var setupSearching : @MainActor(_ isSearching: Bool) -> Void
    let convertCurrency : (_ value: Int, _ from: String?, _ to: String?) -> Int?
    let directoriesManager: DirectoriesManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bg_main
                VStack {
                    TransactionListView(
                        transactions: transactions,
                        getTransactions: getTransactions,
                        deleteTransaction: deleteTransaction,
                        updateUserAmounts: updateUserAmounts,
                        setupSearching: setupSearching,
                        convertCurrency: convertCurrency,
                        directoriesManager: directoriesManager
                    )
                    .toolbar {
                        ToolbarItem (placement: .cancellationAction) {
                            Button("Close") {
                                showView = false
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
                    .searchScopes($searchScope, activation: .onSearchPresentation, {
                        ForEach(scopes, id: \.self) { scope in
                            Text(scope.capitalized)
                        }
                    })
                }
                    .padding()
                    .foregroundColor(.init(white: 0.87))
                    .background(Color.bg_transactions)
            }
        }
    }
}

struct AllTransactuionsView_Previews: PreviewProvider {
    static var previews: some View {
        AllTransactuionsView(
            transactions: [],
            getTransactions: {},
            deleteTransaction: {a in },
            updateUserAmounts: { curId, sumDiff in  },
            showView: .constant(true),
            scopes: ["All", "питание", "здоровье"],
            searchText: .constant(""),
            searchScope: .constant("All"),
            setupSearching: { isSearching in  },
            convertCurrency: {a, b, c in return 0},
            directoriesManager: DirectoriesManager()
        )
    }
}
