import SwiftUI

enum NumberPadType {
    case exchange, original
}

@MainActor
protocol TransactionSendable {
    var hotkeys: [Hotkey]? { get }

    func sendNewTransaction(transaction: Transaction) async throws -> Void
}

struct NewTransactionForm: View, ToastPresentable {

    @State private var toast: ToastType?
    @State private var isExchange: Bool = false // The state for keyboards and number bars
    @State private var selectedNumberPad: NumberPadType = .original

    @ObservedObject var viewModel: NewTransactionViewModel
    @ObservedObject var viewModelExchange: NewTransactionViewModel
    var homeVM: any TransactionSendable
    @EnvironmentObject var rootViewModel: RootTabViewModel
    @AppStorage("currencyIndex") private var currencyIndex: Int = 0

    @Environment(\.presentationMode) var presentationMode

    init(viewModel: NewTransactionViewModel, viewModelExchange: NewTransactionViewModel, homeVM: any TransactionSendable) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _viewModelExchange = ObservedObject(wrappedValue: viewModelExchange)
        self.homeVM = homeVM
    }

    var body: some View {
        ZStack(alignment: .top) {

            VStack {
                TransactionFormHeaderView(
                    onDismiss: { presentationMode.wrappedValue.dismiss() },
                    onExchange: { onPressExchange() }
                )

                Type_CategoryView(
                    categories: rootViewModel.categories,
                    selection: $viewModel.category,
                    type: $viewModel.type
                )
                VStack {
                    Spacer(minLength: 0)
                    //  Sum & Desciption
                    NumberPad(
                        sum: viewModel.sum,
                        type: viewModel.type,
                        currency: viewModel.currency,
                        switchCurrency: { switchCurrency(isExchange: false) },
                        onSwipeRight: { viewModel.onPressBackspace(btn: "") },
                        isExchange: false
                    )
                    .onAppear {
                        viewModel.currency = rootViewModel.currencies?[currencyIndex]
                        viewModel.currentCurrencyInd = currencyIndex
                    }
                    .foregroundColor( selectedNumberPad == .original && isExchange ? Color.accentColor : nil )
                    .onTapGesture { selectedNumberPad = .original }

                    if isExchange {
                        NumberPad(
                            sum: viewModelExchange.sum,
                            type: viewModelExchange.type,
                            currency: viewModelExchange.currency,
                            switchCurrency: { switchCurrency(isExchange: true) },
                            onSwipeRight: { viewModelExchange.onPressBackspace(btn: "") },
                            isExchange: true
                        )
                        .foregroundColor( selectedNumberPad == .exchange ? Color.accentColor : nil )
                        .onTapGesture { selectedNumberPad = .exchange }
                    } else {
                        SubcategoryInput(subcategory: $viewModel.subCategory)
                            .frame(height: 30)
                        SliderPad(
                            onPressOperationButton: viewModel.calcualte,
                            onPressHotkey: viewModel.onPressHotkey,
                            homeVM: homeVM
                        )
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal)

                switch selectedNumberPad {
                case .exchange:
                    Keyboard(
                        viewModel: viewModelExchange,
                        onSwipeUp: {
                            do {
                                try viewModel.validate()
                                presentationMode.wrappedValue.dismiss()
                                try await sendTransaction()
                            } catch let error as AppError {
                                showToast(.error(error.description), binding: $toast)
                            }
                        }
                    )
                case .original:
                    Keyboard(
                        viewModel: viewModel,
                        onSwipeUp: {
                            do {
                                try viewModel.validate()
                                presentationMode.wrappedValue.dismiss()
                                try await sendTransaction()
                            } catch let error as AppError {
                                showToast(.error(error.description), binding: $toast)
                            }
                        }
                    )
                }
            }
            .foregroundColor(.white)
            .background(BackgroundCloud(height: 1500).offset(y:700))
            .background(BackgroundCloud(posX: -30, posY: -140, width: 700, height: 450))
            .background(Color.bg_main.ignoresSafeArea())

            if let toast = toast {
                ToastBanner(type: toast)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: toast)

    }
}

struct NewTransactionForm_Previews: PreviewProvider {
    static var previews: some View {
        let mockHomeVM = MockHomeViewModel()
        NewTransactionForm(viewModel: NewTransactionViewModel(), viewModelExchange: NewTransactionViewModel(), homeVM: mockHomeVM)
    }
}

extension NewTransactionForm {

    private func sendTransaction() async throws -> Void {
        if let category = viewModel.category, let currency = viewModel.currency {
            let transaction = Transaction(
                id: UUID().uuidString,
                category: category,
                subcategory: viewModel.subCategory,
                date: Date(),
                sum: viewModel.type == .income ? viewModel.sum : -viewModel.sum,
                currency: currency,
                type: viewModel.type
            )
            try await homeVM.sendNewTransaction(transaction: transaction)
        }
        // Send the second transaction only if the exchange mode is ON
        if isExchange {
            if let category = viewModelExchange.category, let currency = viewModelExchange.currency {
                let transaction = Transaction(
                    id: UUID().uuidString,
                    category: category,
                    subcategory: viewModelExchange.subCategory,
                    date: Date(),
                    sum: viewModelExchange.sum,
                    currency: currency,
                    type: viewModelExchange.type
                )
                try await homeVM.sendNewTransaction(transaction: transaction)
            }
        }
    }

    private func switchCurrency(isExchange: Bool) {
        if isExchange {
            viewModelExchange.switchCurrency(currencies: rootViewModel.currencies)
        } else {
            currencyIndex = viewModel.switchCurrency(currencies: rootViewModel.currencies)
        }
    }

    private func onPressExchange() {
        isExchange.toggle()
        if viewModel.type == .exchange {
            viewModel.type = .expense
            viewModel.category = nil
            viewModel.subCategory = ""
        } else {
            viewModel.type = .exchange
            viewModel.category = rootViewModel.categories?.first { $0.type == .exchange }
            viewModel.subCategory = "обмен"
        }
        viewModelExchange.currency = viewModel.currency
        viewModelExchange.currentCurrencyInd = currencyIndex
        viewModelExchange.type = .exchange
        viewModelExchange.category = rootViewModel.categories?.first { $0.type == .exchange }
        viewModelExchange.subCategory = "обмен"

        if selectedNumberPad == .exchange {selectedNumberPad = .original}
    }
}
