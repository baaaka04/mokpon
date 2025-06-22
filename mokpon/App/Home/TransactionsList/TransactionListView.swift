import SwiftUI

struct TransactionListView: View {
    
    @AppStorage("mainCurrency") private var mainCurrency: String = "USD"
    
    let transactions: [Transaction]
    let getTransactions: @MainActor() -> ()
    let deleteTransaction: @MainActor(_ transaction: Transaction) -> ()
    let updateUserAmounts: (_ curId: String, _ sumDiff : Int) async throws -> ()
    var transactionLimit: Int? = nil
    let convertCurrency: (_ value: Int, _ from: String?, _ to: String?) -> Int?
    let directoriesManager: DirectoriesManager

    func transformTransactions(trans: [Transaction], limit: Int?) -> [EnumeratedSequence<Array<Dictionary<Date, [Transaction]>.Element>>.Element] {
        var arr = trans
        if let limit, trans.count > limit {arr = Array(trans[0..<limit])}
        let transactionsByDate: Dictionary<Date,[Transaction]> = Dictionary(grouping: arr, by: { (element: Transaction) in
            return Calendar.current.startOfDay(for: element.date)
        })
        // We need an array to define the last group
        // Enumerated - to be able using index
        return Array(transactionsByDate.sorted(by: {(a, b) in return b.key < a.key }))
            .enumerated()
            .sorted{$1.element.key < $0.element.key}
    }
    
    @MainActor
    func convertCurrency(trans: [Transaction]) -> Int {
        trans.reduce(0, {acc, trans in acc + (convertCurrency(trans.sum, trans.currency.name, mainCurrency) ?? 0)})
    }
    
    func getCurrencyByName(name: String) -> Currency? {
        directoriesManager.getCurrency(byName: name)
    }
    
    var body: some View {
        
        VStack {
            if !transactions.isEmpty {

                List (transformTransactions(trans: transactions, limit: transactionLimit), id: \.element.key) { (index, transGrouped) in
                    Section {
                        ForEach (transGrouped.value, id: \.self.id) { item in
                            ExpenseView(transaction: item)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Rectangle().background(.clear).padding())
                                .onAppear {
                                    let count = transactions.count
                        // Download new transactions only if the 5th from the end appeared
                        // Skip loading if it's HomeView with its limit
                                    if transactionLimit == nil && count >= 5 && item == transactions[count - 5] {
                                        getTransactions()
                                    }
                                }
                        }
                        .onDelete { indexSet in
                            for i in indexSet.makeIterator() {
                                let item = transGrouped.value[i]
                                Task {
                                    deleteTransaction(item)
                                    try await updateUserAmounts(item.currency.id, -item.sum)
                                }
                            }
                        }
                    } header : {
                        HStack{
                            let date = transGrouped.key
                            let dateCheck = Calendar.current
                            Text(dateCheck.isDateInToday(date) ? "Today" : dateCheck.isDateInYesterday(date) ? "Yesterday" : date.formatted(date: .abbreviated, time: .omitted))
                            Spacer()
                            if let currencySymbol = getCurrencyByName(name:mainCurrency)?.symbol {
                                Text("\(convertCurrency(trans:transGrouped.value))\(currencySymbol)")
                            } else {
                                Text("---")
                            }
                        }
                        .font(.headline)
                        .padding(.horizontal)
                        .frame(height: 30)
                    }
                }
                .environment(\.defaultMinListRowHeight, 100)
                .listStyle(.plain)
            } else {
                VStack (alignment: .center) {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: .infinity)
            }

        }
        .task {
            guard !transactions.isEmpty else {
                getTransactions()
                return
            }
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView(
            transactions: [],
            getTransactions: {},
            deleteTransaction: {a in },
            updateUserAmounts: { curId, sumDiff in  },
            transactionLimit: 6,
            convertCurrency: {a,b,c in return 0},
            directoriesManager: DirectoriesManager()
        )
    }
}
