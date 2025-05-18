import SwiftUI

struct Home: View {

    @StateObject private var vm: HomeViewModel

    init(viewModel: HomeViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        ZStack(alignment: .bottomTrailing) {

            CustomRefreshView {
                VStack{
                    DebitCard(amounts: vm.amounts, directoriesManager: vm.directoriesManager)
                        .task {
                            guard vm.amounts == nil else { return }
                            vm.getUserAmounts()
                        }

                    Currencies(
                        fetchCurrencyRates: vm.fetchCurrencyRates,
                        RUBKGS: vm.currencyRates?.RUBKGS,
                        USDKGS: vm.currencyRates?.USDKGS,
                        EURKGS: vm.currencyRates?.EURKGS
                    )
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)

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
                                AllTransactionsView (
                                    transactions: vm.transactions,
                                    getTransactions: vm.getTransactions,
                                    updateTransactions: vm.updateTransactions,
                                    deleteTransaction: vm.deleteTransaction,
                                    updateUserAmounts: vm.updateUserAmount,
                                    showView: $vm.showAllTransactions,
                                    convertCurrency: vm.currencyRatesService.convertCurrency,
                                    directoriesManager: vm.directoriesManager,
                                    searchText: $vm.searchtext,
                                    selectedScope: $vm.selectedScope,
                                    searchScopes: vm.searchScopes
                                )
                                .presentationDragIndicator(.visible)
                            }
                        }
                        .padding(.top)
                        TransactionListView(
                            transactions: vm.transactions,
                            getTransactions: vm.getTransactions,
                            updateTransactions: vm.updateTransactions,
                            deleteTransaction: vm.deleteTransaction,
                            updateUserAmounts: vm.updateUserAmount,
                            transactionLimit: 5, //show only last 5 transactions
                            convertCurrency: vm.currencyRatesService.convertCurrency,
                            directoriesManager: vm.directoriesManager
                        )
                    }
                    .padding(.horizontal)
                    .foregroundColor(.init(white: 0.87))
                    .background(Color.bg_transactions)
                    Spacer()
                }
                .frame(minHeight: 1100)
            } onRefresh: {
                vm.updateTransactions()
                vm.fetchCurrencyRates()
                vm.getUserAmounts()
            }

            NavigationLink(value: "") { // I need it only because of 'Lazyness', to prevent initializing NewTransactionViewModel every HomeView's render
                AddButton()
                    .padding(30)
                    .onAppear {
                        vm.getHotkeys()
                    }
            }
            .padding(.bottom, 40)
        }
        .font(.custom("DMSans-Regular", size: 16))
        .navigationDestination(for: String.self) { _ in
            NewTransactionForm(
                viewModel: NewTransactionViewModel(),
                viewModelExchange: NewTransactionViewModel(),
                homeVM: vm
            )
            .navigationBarHidden(true)
            .id(UUID()) // Recreate the view every render to initiate onAppear method inside. 
        }
    }
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home(viewModel: HomeViewModel(appContext: AppContext()))
    }
}
