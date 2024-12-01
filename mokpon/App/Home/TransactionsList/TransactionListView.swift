import SwiftUI

struct TransactionListView: View {
    
    @AppStorage("mainCurrency") private var mainCurrency : String = "USD"
    
    let transactions: [Transaction]
    let getTransactions: @MainActor() -> ()
    let deleteTransaction: @MainActor(_ transactionId: String) -> ()
    let updateUserAmounts: (_ curId: String, _ sumDiff : Int) async throws -> ()
    var setupSearching: @MainActor(_ isSearching: Bool) -> Void
    var transactionLimit: Int? = nil
    let convertCurrency: (_ value: Int, _ from: String?, _ to: String?) -> Int?
    let directoriesManager: DirectoriesManager
    
    @Environment(\.isSearching) private var isSearching
    
    func transformTransactions (trans: [Transaction], limit: Int?) -> [EnumeratedSequence<Array<Dictionary<Date, [Transaction]>.Element>>.Element] {
        var arr = trans
        if let limit, trans.count > limit {arr = Array(trans[0..<limit])}
        let transactionsByDate: Dictionary<Date,[Transaction]> = Dictionary(grouping: arr, by: { (element: Transaction) in
            return Calendar.current.startOfDay(for: element.date)
        })
        //we need an array to define the last group
        //enumerate - to be able using index
        return Array(transactionsByDate.sorted(by: {(a, b) in return b.key < a.key }))
            .enumerated()
            .sorted{$1.element.key < $0.element.key}
    }
    
    @MainActor
    func convertCurrency (trans: [Transaction]) -> Int {
        trans.reduce(0, {acc, trans in acc + (convertCurrency(trans.sum, trans.currency.name, mainCurrency) ?? 0)})
    }
    
    func getCurrencyByName (name: String) -> Currency? {
        directoriesManager.getCurrency(byName: name)
    }
    
    var body: some View {
        
        VStack {
            if transactions.count != 0 {
                
                List (transformTransactions(trans: transactions, limit: transactionLimit), id: \.element.key) { (index, transGrouped) in
                    Section {
                        ForEach (transGrouped.value, id: \.self.id) { item in
                            ExpenseView(transaction: item)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Rectangle().background(.clear).padding())
                            if item == transactions[transactions.count - 5] {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .onAppear {
                                        getTransactions()
                                    }
                            }
                        }
                        .onDelete { indexSet in
                            for i in indexSet.makeIterator() {
                                let theItem = transGrouped.value[i]
                                Task {
                                    deleteTransaction(theItem.id)
                                    try await updateUserAmounts(theItem.currency.id, -theItem.sum)
                                    getTransactions()
                                }
                            }
                        }
                    } header : {
                        HStack{
                            let date = transGrouped.key
                            let dateCheck = Calendar.current
                            Text(dateCheck.isDateInToday(date) ? "Today" : dateCheck.isDateInYesterday(date) ? "Yesterday" : date.formatted(date: .abbreviated, time: .omitted))
                            Spacer()
                            Text("\(convertCurrency(trans:transGrouped.value))\(getCurrencyByName(name:mainCurrency)?.symbol ?? "")")
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
            if self.transactions.isEmpty {
                getTransactions()
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
            setupSearching: {x in },
            transactionLimit: 6,
            convertCurrency: {a,b,c in return 0},
            directoriesManager: DirectoriesManager()
        )
    }
}
