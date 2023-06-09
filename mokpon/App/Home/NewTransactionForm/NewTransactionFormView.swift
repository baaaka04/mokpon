import SwiftUI


struct NewTransactionForm: View {
    
    @StateObject private var viewModel = NewTransactionViewModel()
    
    var sendNewTransaction : (Transaction) async -> Void
    
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
                Button {viewModel.isCalcVisible = !viewModel.isCalcVisible} label: {
                    Label(title: {Text("Calculate")}, icon: {Image(systemName: "sum")})
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
                HStack {
                    Text(viewModel.type != .income ? "-" : "")
                    Spacer()
                    HStack {
                        switch viewModel.currency {
                        case .KGS:
                            Text("c").underline()
                                .onTapGesture {
                                    viewModel.currency = .RUB
                                }
                        case .RUB:
                            Text("₽").onTapGesture {
                                viewModel.currency = .KGS
                            }
                        }
                        Spacer()
                        Text("\(viewModel.sum)")
                            .lineLimit(1)
                    }
                }
                .minimumScaleFactor(0.3)
                .padding(.vertical, 30)
                .font(.custom("gothicb", size: 62))
                Spacer(minLength: 0)
                // Using ZStack to color the placeholder
                ZStack(alignment: .leading) {
                    if viewModel.subCategory.isEmpty {
                        Text("Add Description")
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.horizontal, 10)
                    }
                    TextField("", text: $viewModel.subCategory )
                        .onChange(of: viewModel.subCategory) { _ in
                            let newText = String(viewModel.subCategory.prefix(35))
                            viewModel.subCategory = newText
                        }
                        .padding(4)
                        .overlay(Rectangle()
                            .frame(width: nil, height: 1, alignment: .bottom)
                            .foregroundColor(.yellow), alignment: .bottom)
                        .accentColor(.yellow)
                }
                .frame(height: 30)
                VStack {
                    if viewModel.isCalcVisible {
                        CalculatorView(onPressOperationButton: viewModel.calcualte)
                    } else {
                        HotkeysView(
                            onPressHotkey: viewModel.onPressHotkey,
                            hotkeys: viewModel.hotkeys,
                            fetchHotkeys: viewModel.fetchHotkeys
                        )
                    }
                }
                .frame(height: 60)
                .padding(.bottom, 10)
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(.yellow), alignment: .bottom)
            }
            .padding(.horizontal)
            
            Keyboard(
                onPressDigit: viewModel.onPressDigit,
                onPressClear: viewModel.onPressClear,
                onPressBackspace: viewModel.onPressBackspace,
                onSwipeUp: {
                    await sendNewTransaction(Transaction(category: viewModel.category ?? "", subCategory: viewModel.subCategory, type: viewModel.type, date: .now, sum: viewModel.sum))
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .font(.system(size: 32))
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
        NewTransactionForm(sendNewTransaction: {(transaction) -> Void in return})
    }
}
