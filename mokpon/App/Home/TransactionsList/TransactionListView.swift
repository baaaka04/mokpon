import SwiftUI

struct TransactionListView: View {
    
    let transactions : [Transaction]
    let fetchTransactions : () async -> Void
    var isLoading : Bool
        
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
                }
                .frame(maxHeight: .infinity)
            } else {
                List (transactionsInArray, id: \.element.key) { (index, transGrouped) in
                    Section {
                        ForEach (transGrouped.value, id: \.self.id) { item in
                            TransactionView(trans: item, isLast: index == transactionsInArray.count - 1, isLoading: isLoading)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Rectangle().background(.clear).padding())
                        }
                        .onDelete(perform: {index in })
                    } header : {
                        HStack{
                            Text(transGrouped.key.formatted(date: .abbreviated, time: .omitted))
                                .font(.headline)
                                .padding(.horizontal)
                            Spacer()
                        }
                        .frame(height: 30)
                    }
                }
                .environment(\.defaultMinListRowHeight, 100)
                .listStyle(.plain)
            }
        }
        .onAppear {
            //            fetch transactions only if it's the first appearance
            if transactions.count == 0 {
                Task {
                    await fetchTransactions()
                }
            }
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView(transactions: [
            Transaction(category: "food", subCategory: "healthy", type: .expense, date: Date(), sum: 200),
            Transaction(category: "food", subCategory: "healthy", type: .expense, date: Date(), sum: 200),
            Transaction(category: "transport", subCategory: "taxi", type: .expense, date: Date(), sum: 150)
        ], fetchTransactions: HomeViewModel().fetchTransactions, isLoading: false)
    }
}
