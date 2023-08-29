import SwiftUI

struct Home: View {
    
    @StateObject var vm = HomeViewModel()
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                VStack{
                    
                    DebitCard()
                    
                    Currencies(
                        fetchCurrencyRates: vm.fetchCurrencyRates,
                        usdrub: vm.currencyRates.RUB,
                        usdkgs: vm.currencyRates.KGS
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
                                    transactions: vm.isSearching ? vm.filteredTransactions : vm.transactions,
                                    fetchTransactions: vm.getLastTransactions,
                                    isLoading: vm.isLoading,
                                    showView: $vm.showAllTransactions,
                                    scopes: vm.allSearchScopes,
                                    searchText: $vm.searchtext,
                                    searchScope: $vm.searchScope,
                                    setupSearching: vm.setupSearching
                                )
                            }
                        }
                        .padding(.top)
                        TransactionListView(
                            transactions: vm.transactions,
                            fetchTransactions: vm.getLastTransactions,
                            isLoading: vm.isLoading,
                            setupSearching: { isSearching in  },
                            transactionLimit: 5 //show only last 5 transactions
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
                vm.getLastTransactions()
                vm.fetchCurrencyRates()
            }
            
            
            VStack {
                Spacer()
                
                HStack{
                    Spacer()
                    NavigationLink(
                        destination:
                            NewTransactionForm()
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
