import SwiftUI

struct AllTransactuionsView: View {
    
    let transactions : [Transaction]
    let fetchTransactions : () async -> Void
    var isLoading : Bool
    @Binding var showView : Bool
    
    //searching
    let scopes : [String]
    @Binding var searchText : String
    @Binding var searchScope : String
    var setupSearching : (_ isSearching: Bool) -> Void
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bg_main
                VStack {
                    TransactionListView(
                        transactions: transactions,
                        fetchTransactions: fetchTransactions,
                        isLoading: isLoading,
                        setupSearching: setupSearching
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
            transactions: [
                Transaction(category: "food", subCategory: "healthy", type: .expense, date: Date(), sum: 200),
                Transaction(category: "food", subCategory: "healthy", type: .expense, date: Date(), sum: 200),
                Transaction(category: "transport", subCategory: "taxi", type: .expense, date: Date(), sum: 150)
            ],
            fetchTransactions: HomeViewModel().fetchTransactions,
            isLoading: false,
            showView: .constant(true),
            scopes: ["All", "питание", "здоровье"],
            searchText: .constant(""),
            searchScope: .constant("All"),
            setupSearching: { isSearching in  }
        )
    }
}
