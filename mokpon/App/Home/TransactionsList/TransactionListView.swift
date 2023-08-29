import SwiftUI

struct TransactionListView: View {
    
    let transactions : [Transaction]?
    let fetchTransactions : @MainActor() -> ()
    var isLoading : Bool
    var setupSearching : @MainActor(_ isSearching: Bool) -> Void
    var transactionLimit : Int? = nil
    
    @Environment(\.isSearching) private var isSearching
    
    func transformTransactions (trans: [Transaction], limit: Int?) -> [EnumeratedSequence<Array<Dictionary<Date, [Transaction]>.Element>>.Element] {
        var arr = trans
        if let limit {arr = Array(trans[0..<limit])}
        let transactionsByDate: Dictionary<Date,[Transaction]> = Dictionary(grouping: arr, by: { (element: Transaction) in
            return Calendar.current.startOfDay(for: element.date)
        })
        //we need an array to define the last group
        //enumerate - to be able using index
        return Array(transactionsByDate.sorted(by: {(a, b) in return b.key < a.key }))
            .enumerated()
            .sorted{$1.element.key < $0.element.key}
    }
    
    var body: some View {
        
        VStack {
            if let transactions {
                
                List (transformTransactions(trans: transactions, limit: transactionLimit), id: \.element.key) { (index, transGrouped) in
                    Section {
                        ForEach (transGrouped.value, id: \.self.id) { item in
                            ExpenseView(transaction: item, isLast: index == transactions.count - 1, isLoading: isLoading)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Rectangle().background(.clear).padding())
                        }
                        //                        .onDelete(perform: {index in })
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
            } else {
                VStack (alignment: .center) {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: .infinity)
            }
            
        }
        .task {
            fetchTransactions()
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView(
            transactions: [],
            fetchTransactions: {}, isLoading: false, setupSearching: {x in }, transactionLimit: 6)
    }
}
