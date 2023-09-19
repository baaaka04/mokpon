import SwiftUI

enum NumberPadType {
    case exchange, original
}

struct NewTransactionForm: View {
    
    @ObservedObject var viewModel = NewTransactionViewModel(isExchange: false)
    @ObservedObject var viewModelExchange = NewTransactionViewModel(isExchange: true)
    @EnvironmentObject var globalViewModel : GlobalViewModel
    @AppStorage("currencyIndex") private var currencyIndex : Int = 0
    
    @State private var isExchange : Bool = false
    @State private var selectedNumberPad : NumberPadType = .original
    @State private var selectedTabIndex = 1
    
    @Environment(\.presentationMode) var presentationMode
    
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
                NumberPad(sum: viewModel.sum, type: viewModel.type, currency: viewModel.currency, switchCurrency: {switchCurrency(isExchange: false)}, onSwipeRight: {viewModel.onPressBackspace(btn: "")}, isExchange: viewModel.isExchange)
                    .onAppear {
                        viewModel.currency = globalViewModel.currencies?[currencyIndex]
                        viewModel.currentCurrencyInd = currencyIndex
                    }
                    .foregroundColor( selectedNumberPad == .original && isExchange ? Color.accentColor : nil )
                    .onTapGesture { selectedNumberPad = .original }
                
                if isExchange {
                    NumberPad(sum: viewModelExchange.sum, type: viewModelExchange.type, currency: viewModelExchange.currency, switchCurrency: {switchCurrency(isExchange: true)}, onSwipeRight: {viewModelExchange.onPressBackspace(btn: "")}, isExchange: true)
                        .foregroundColor( selectedNumberPad == .exchange ? Color.accentColor : nil )
                        .onTapGesture { selectedNumberPad = .exchange }
                }

                Spacer(minLength: 0)
                
                if !isExchange { //TODO: create a separated component
                    SubcategoryInput(subcategory: $viewModel.subCategory)
                        .frame(height: 30)
                    
                    VStack {
                        TabView (selection: $selectedTabIndex) {
                            CalculatorView(onPressOperationButton: viewModel.calcualte)
                                .tag(0)
                            HotkeysView(
                                onPressHotkey: viewModel.onPressHotkey,
                                hotkeys: viewModel.hotkeys,
                                fetchHotkeys: viewModel.getHotkeys
                            )
                            .tag(1)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .local)
                            .onEnded { value in
                                if value.translation.width > 0 { switchTabToHotkeys() }
                                if value.translation.width < 0 { switchTabToCalculator () }
                            }
                        )
                    }
                    .frame(height: 60)
                    .padding(.bottom, 10)
                    .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(.yellow), alignment: .bottom)
                }
            }
            .padding(.horizontal)
            
            Group {
                switch selectedNumberPad {
                case .exchange: Keyboard(viewModel: viewModelExchange, onSwipeUp: sendTransaction)
                case .original: Keyboard(viewModel: viewModel, onSwipeUp: sendTransaction)
                }
            }.font(.system(size: 32))
        }
        .foregroundColor(.white)
        .background(Rectangle()
            .fill(EllipticalGradient(
                gradient: Gradient(colors: [
                    Color.bg_secondary,
                    Color.bg_main,
                ]),
                center: .center,
                startRadiusFraction: 0.01,
                endRadiusFraction: 0.5)
            )
                .ignoresSafeArea()
                .frame(width: 700, height: 450)
                .position(x: -30, y: -140)
                .opacity(0.5)
        )
        .background(Rectangle()
            .fill(EllipticalGradient(
                gradient: Gradient(colors: [
                    Color.bg_secondary,
                    Color.bg_main
                ]),
                center: .center,
                startRadiusFraction: 0.01,
                endRadiusFraction: 0.5)
            )
                .frame(height: 1500)
                .offset(y: 600)
                .opacity(0.3)
        )
        .background(Color.bg_main.ignoresSafeArea())
    }
}

struct NewTransactionForm_Previews: PreviewProvider {
    static var previews: some View {
        NewTransactionForm().environmentObject(GlobalViewModel())
    }
}

extension NewTransactionForm {
    
    func sendTransaction () {
        Task {
            try await viewModel.sendNewTransaction()
            try await viewModel.updateUserAmounts()
            
            if isExchange {
                try await viewModelExchange.sendNewTransaction()
                try await viewModelExchange.updateUserAmounts()
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
    private func switchCurrency (isExchange: Bool) {
        if isExchange {
            viewModelExchange.switchCurrency(currencies: globalViewModel.currencies)
        } else {
            currencyIndex = viewModel.switchCurrency(currencies: globalViewModel.currencies)
        }
    }
    private func switchTabToCalculator () {
        if selectedTabIndex == 0 { withAnimation{ selectedTabIndex = 1 } }
    }
    private func switchTabToHotkeys () {
        if selectedTabIndex == 1 { withAnimation{ selectedTabIndex = 0 } }
    }
    private func onPressExchange () {
        isExchange.toggle()
        if viewModel.type == .exchange {
            viewModel.type = .expense
            viewModel.category = nil
            viewModel.subCategory = ""
        } else {
            viewModel.type = .exchange
            viewModel.category = globalViewModel.categories?.first { $0.type == .exchange }
            viewModel.subCategory = "обмен"
        }
        viewModelExchange.currency = viewModel.currency
        viewModelExchange.currentCurrencyInd = currencyIndex
        viewModelExchange.type = .exchange
        viewModelExchange.category = globalViewModel.categories?.first { $0.type == .exchange }
        viewModelExchange.subCategory = "обмен"
        
        if selectedNumberPad == .exchange {selectedNumberPad = .original}
    }
}
