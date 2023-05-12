import SwiftUI

struct Home: View {
    
    @StateObject var vm = HomeViewModel()
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                VStack{
                    
                    DebitCard()
                    
                    Currencies(
                        fetchCurrency: vm.fetchCurrency,
                        usdrub: vm.currencies.RUB,
                        usdkgs: vm.currencies.KGS
                    )
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)
                    //GroupBy for dates
                    VStack {
                        HStack{
                            Text("My transactions")
                                .font(.custom("DMSans-Regular", size: 20))
                            Spacer()
                            
                            Button("Show all") {
                                vm.showAllTransactions = true
                            }
                            .font(.custom("DMSans-Regular", size: 14))
                            .foregroundColor(Color.accentColor)
                            .popover(isPresented: $vm.showAllTransactions) {
                                AllTransactuionsView (
                                    transactions: vm.transactions,
                                    fetchTransactions: vm.fetchTransactions,
                                    isLoading: vm.isLoading,
                                    showView: $vm.showAllTransactions
                                )
                            }
                        }
                        .padding(.top)
                        TransactionListView(
                            transactions: vm.transactions.count < 5 ? vm.transactions : Array(vm.transactions[0...4]),
                            fetchTransactions: vm.fetchTransactions,
                            isLoading: vm.isLoading
                        )
                    }
                    .padding(.horizontal)
                    .foregroundColor(.init(white: 0.87))
                    .background(Color.bg_transactions)
                    Spacer()
                }
                .frame(minHeight: 1100)
            }
            .refreshable {
                await vm.fetchTransactions()
                await vm.fetchCurrency()
            }
            
            
            VStack {
                Spacer()
                
                HStack{
                    Spacer()
                    NavigationLink(
                        destination:
                            NewTransactionForm(sendNewTransaction: vm.sendNewTransaction)
                            .navigationBarHidden(true),
                        label: {
                            AddButton()
                                .padding(40)
                        }
                    )
                }
                .padding(.bottom, 35)
            }
        }
        .font(.custom("DMSans-Regular", size: 16))
    }
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
