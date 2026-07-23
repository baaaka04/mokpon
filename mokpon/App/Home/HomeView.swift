import SwiftUI

struct Home: View {

    @StateObject private var vm: HomeViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showTransactions: Bool = false

    init(viewModel: HomeViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        ZStack(alignment: .bottomTrailing) {
            CustomRefreshView {
                VStack(spacing: 10) {
                    DebitCard(
                        cardholderName: authViewModel.user?.name,
                        amounts: vm.amounts,
                        directoriesManager: vm.directoriesManager
                    )

                    Currencies(
                        fetchCurrencyRates: vm.fetchCurrencyRates,
                        RUBKGS: vm.currencyRates?.RUBKGS,
                        USDKGS: vm.currencyRates?.USDKGS,
                        EURKGS: vm.currencyRates?.EURKGS
                    )

                    VStack {
                        HStack{
                            Text("My transactions")
                                .font(.custom("DMSans-Regular", size: 20))
                            Spacer()

                            Button("Show all") {
                                showTransactions = true
                            }
                            .font(.custom("DMSans-Regular", size: 14))
                            .foregroundColor(Color.accentColor)
                        }
                        .padding(.horizontal)

                        TransactionListView(
                            transactions: vm.transactions,
                            deleteTransaction: vm.deleteTransaction,
                            convertCurrency: vm.currencyRatesService.convertCurrency,
                            directoriesManager: vm.directoriesManager
                        )
                    }
                    .padding(.vertical)
                    .foregroundColor(.init(white: 0.87))
                    .background(Color.bg_transactions)
                    Spacer()
                }
                .frame(minHeight: 1100)
            } onRefresh: {
                vm.getHomeTransactions()
                vm.fetchCurrencyRates()
                vm.getUserAmounts()
            }

            NavigationLink(value: "") { // I need it only because of 'Lazyness', to prevent initializing NewTransactionViewModel every HomeView's render
                AddButton()
            }
            .padding(.bottom, 40)
        }
        .font(.custom("DMSans-Regular", size: 16))
        .navigationDestination(for: String.self) { _ in
            NewTransactionForm(homeVM: vm)
                .navigationBarHidden(true)
        }
        .popover(isPresented: $showTransactions) {
            AllTransactionsView(
                transactions: vm.filteredTransactions,
                getTransactions: vm.getTransactions,
                deleteTransaction: vm.deleteTransaction,
                convertCurrency: vm.currencyRatesService.convertCurrency,
                directoriesManager: vm.directoriesManager,
                searchText: $vm.searchtext,
                selectedScope: $vm.selectedScope,
                searchScopes: vm.searchScopes
            )
            .presentationDragIndicator(.visible)
        }
        .task {
            if vm.transactions.isEmpty {
                vm.getHomeTransactions()
            }
            vm.getHotkeys()
            guard vm.amounts == nil else { return }
            vm.getUserAmounts()
            guard authViewModel.user == nil else { return }
            try? await authViewModel.loadAuthUser()
        }
    }
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home(viewModel: HomeViewModel(appContext: AppContext()))
    }
}
