import SwiftUI

struct TransactionListView: View {
    
    @AppStorage("mainCurrency") private var mainCurrency: Currency = .usd

    let transactions: [Transaction]
    let deleteTransaction: (_ transaction: Transaction) async throws -> ()
    let convertCurrency: (_ value: Int, _ from: String?, _ to: String?) -> Int?
    var loadMore: (() -> Void)?

    func transformTransactions(trans: [Transaction]) -> [EnumeratedSequence<Array<Dictionary<Date, [Transaction]>.Element>>.Element] {
        let transactionsByDate: Dictionary<Date,[Transaction]> = Dictionary(grouping: trans, by: { (element: Transaction) in
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
        trans.reduce(0, {acc, trans in acc + (convertCurrency(trans.sum, trans.currency.name, mainCurrency.name) ?? 0)})
    }

    var body: some View {
        
        VStack {
            if !transactions.isEmpty {
                List(transformTransactions(trans: transactions), id: \.element.key) { (index, transGrouped) in
                    Section {
                        ForEach (transGrouped.value, id: \.self.id) { item in
                            let subtitle = item.date.formatted(.dateTime.day().month().year().hour().minute())
                            let number = "\(item.sum)\(item.currency.symbol)"
                            ExpenseView(
                                title: item.subcategory,
                                subtitle: subtitle,
                                icon: item.category.icon,
                                number: number
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Rectangle().fill(.clear))
                            .onAppear {
                                if item == transactions.last {
                                    loadMore?()
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for i in indexSet.makeIterator() {
                                let item = transGrouped.value[i]
                                Task {
                                    try await deleteTransaction(item)
                                }
                            }
                        }
                    } header : {
                        HStack{
                            let date = transGrouped.key
                            let dateCheck = Calendar.current
                            Text(dateCheck.isDateInToday(date) ? "Today" : dateCheck.isDateInYesterday(date) ? "Yesterday" : date.formatted(date: .abbreviated, time: .omitted))
                            Spacer()
                            
                            Text("\(convertCurrency(trans:transGrouped.value))\(mainCurrency.symbol)")
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
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView(
            transactions: [],
            deleteTransaction: {a in },
            convertCurrency: {a,b,c in return 0},
        )
    }
}
