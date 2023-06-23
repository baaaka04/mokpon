import SwiftUI

struct TransactionListView: View {
    
    let transactions : [Transaction]
    let fetchTransactions : () async -> Void
    var isLoading : Bool
    var setupSearching : (_ isSearching: Bool) -> Void
    
    @Environment(\.isSearching) private var isSearching
    
    var body: some View {
        //using Dictionary to group by date
        let transactionsByDate: Dictionary<Date,[Transaction]> = Dictionary(grouping: transactions, by: { (element: Transaction) in
            return element.date
        })
        //we need an array to define the last group
        //enumerate - to be able using index
        let transactionsInArray = Array(transactionsByDate.sorted(by: {(a, b) in return b.key < a.key }))
            .enumerated()
            .sorted{$1.element.key < $0.element.key}
        
        VStack {
            if transactions.count == 0 {
                VStack (alignment: .center) {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: .infinity)
            } else {
                List (transactionsInArray, id: \.element.key) { (index, transGrouped) in
                    Section {
                        ForEach (transGrouped.value, id: \.self.id) { item in
                            ExpenseView(transaction: item, isLast: index == transactionsInArray.count - 1, isLoading: isLoading)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Rectangle().background(.clear).padding())
                        }
                        .onDelete(perform: {index in })
                    } header : {
                        HStack{
                            let date = transGrouped.key
                            let dateCheck = Calendar.current
                            Text(dateCheck.isDateInToday(date) ? "Today" : dateCheck.isDateInYesterday(date) ? "Yesterday" : date.formatted(date: .abbreviated, time: .omitted))
                            Spacer()
                            Text("\(transGrouped.value.reduce(0, {acc, trans in acc + trans.sum})) ₽")
                        }
                        .font(.headline)
                        .padding(.horizontal)
                        .frame(height: 30)
                    }
                }
                .environment(\.defaultMinListRowHeight, 100)
                .listStyle(.plain)
                //pass child's searching status to viewModel
                .onChange(of: isSearching, perform: { newValue in
                    setupSearching(newValue)
                })
            }
        }
        .task {
            //            fetch transactions only if it's the first appearance
            if transactions.count == 0 {await fetchTransactions()}
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView(transactions: [
            Transaction(category: "food", subCategory: "healthy", type: .expense, date: Date(), sum: 200),
            Transaction(category: "food", subCategory: "healthy", type: .expense, date: Date(), sum: 200),
            Transaction(category: "transport", subCategory: "taxi", type: .expense, date: Date(), sum: 150)
        ], fetchTransactions: HomeViewModel().fetchTransactions, isLoading: false, setupSearching: {x in })
    }
}
