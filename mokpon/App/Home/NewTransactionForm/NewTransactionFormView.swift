import SwiftUI

enum NumberPadType {
    case exchange, original
}

struct NewTransactionForm: View {

    @ObservedObject var viewModel: NewTransactionViewModel
    @ObservedObject var viewModelExchange: NewTransactionViewModel
    @EnvironmentObject var rootViewModel: RootTabViewModel
    @AppStorage("currencyIndex") private var currencyIndex: Int = 0
    var onPressSend: ((_ trans: Transaction) async throws -> Void)? = nil

    @State private var isExchange: Bool = false // The state for keyboards and number bars
    @State private var selectedNumberPad: NumberPadType = .original

    @Environment(\.presentationMode) var presentationMode

    init(viewModel: NewTransactionViewModel, viewModelExchange: NewTransactionViewModel, onPressSend: ((_ trans: Transaction) async throws -> Void)?) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _viewModelExchange = ObservedObject(wrappedValue: viewModelExchange)
        self.onPressSend = onPressSend
    }

    var body: some View {
        VStack {
            HStack{
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label(title: {Text("")}, icon: {Image(systemName: "xmark")})
                }
                Spacer()
                Button {
                    onPressExchange()
                } label: {
                    Label(title: {Text("Exchange")}, icon: {Image(systemName: "arrow.triangle.2.circlepath")})
                }
            }
            .font(.custom("DMSans-Regular", size: 14))
            .foregroundColor(.yellow)
            .padding(.horizontal, 10)

            Type_CategoryView(
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
                        hotkeys: viewModel.hotkeys,
                        fetchHotkeys: viewModel.getHotkeys
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
                        presentationMode.wrappedValue.dismiss()
                        try await sendTransaction()
                    }
                )
            case .original:
                Keyboard(
                    viewModel: viewModel,
                    onSwipeUp: {
                        presentationMode.wrappedValue.dismiss()
                        try await sendTransaction()
                    }
                )
            }
        }
        .foregroundColor(.white)
        .background(BackgroundCloud(height: 1500).offset(y:700))
        .background(BackgroundCloud(posX: -30, posY: -140, width: 700, height: 450))
        .background(Color.bg_main.ignoresSafeArea())
    }
}

struct NewTransactionForm_Previews: PreviewProvider {
    static var previews: some View {
        let appContext = AppContext()
        NewTransactionForm(viewModel: NewTransactionViewModel(appContext: appContext), viewModelExchange: NewTransactionViewModel(appContext: appContext), onPressSend: {(trans) in } )
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
            try await onPressSend?(transaction)
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
                try await onPressSend?(transaction)
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
