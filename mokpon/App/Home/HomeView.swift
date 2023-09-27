import SwiftUI

struct Home: View {
    
    @StateObject private var vm: HomeViewModel
    
    let transactionManager: TransactionManager
    let amountManager: AmountManager
    let authManager: AuthenticationManager
    let directoriesManager: DirectoriesManager
    
    init(currencyRatesService: CurrencyManager, transactionManager: TransactionManager, amountManager: AmountManager, authManager: AuthenticationManager, directoriesManager: DirectoriesManager) {
        self.directoriesManager = directoriesManager
        self.authManager = authManager
        self.transactionManager = transactionManager
        self.amountManager = amountManager
        _vm = StateObject(wrappedValue: HomeViewModel(currencyRatesService: currencyRatesService, transactionManager: transactionManager, amountManager: amountManager, authManager: authManager, directoriesManager: directoriesManager))
    }
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                VStack{
                    
                    DebitCard(amounts: vm.amounts, directoriesManager: directoriesManager)
                        .onAppear {
                            vm.getUserAmounts()
                        }
                    
                    Currencies(
                        fetchCurrencyRates: vm.fetchCurrencyRates,
                        usdrub: vm.currencyRates?.RUB,
                        usdkgs: vm.currencyRates?.KGS
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
                                    getTransactions: vm.getTransactions,
                                    deleteTransaction: vm.deleteTransaction,
                                    updateUserAmounts: vm.updateUserAmount,
                                    showView: $vm.showAllTransactions,
                                    scopes: vm.allSearchScopes,
                                    searchText: $vm.searchtext,
                                    searchScope: $vm.searchScope,
                                    setupSearching: vm.setupSearching,
                                    convertCurrency: vm.currencyRatesService.convertCurrency,
                                    directoriesManager: directoriesManager
                                )
                                .presentationDragIndicator(.visible)
                            }
                        }
                        .padding(.top)
                        TransactionListView(
                            transactions: vm.transactions,
                            getTransactions: vm.getLastTransactions,
                            deleteTransaction : vm.deleteTransaction,
                            updateUserAmounts: vm.updateUserAmount,
                            setupSearching: { isSearching in  },
                            transactionLimit: 5, //show only last 5 transactions
                            convertCurrency: vm.currencyRatesService.convertCurrency,
                            directoriesManager: directoriesManager
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
                vm.getUserAmounts()
            }
            
            
            VStack {
                Spacer()
                
                HStack{
                    Spacer()
                    NavigationLink(
                        destination:
                            NewTransactionForm(transactionManager: transactionManager, amountManager: amountManager, authManager: authManager, directoriesManager: directoriesManager)
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
        Home(currencyRatesService: CurrencyManager(completion: {}), transactionManager: TransactionManager(), amountManager: AmountManager(), authManager: AuthenticationManager(), directoriesManager: DirectoriesManager(completion: {}))
    }
}
