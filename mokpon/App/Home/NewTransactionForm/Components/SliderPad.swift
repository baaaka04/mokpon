import SwiftUI

struct SliderPad: View {
    
    @State private var selectedTabIndex = 1
    let onPressOperationButton: @MainActor(_ key: String) -> Void
    let onPressHotkey: @MainActor(_ category: Category, _ subcategory: String) -> Void
    var homeVM: TransactionSendable
    
    var body: some View {
        VStack {
            if let chunks = homeVM.hotkeys?.chunked(into: 8) {
                TabView(selection: $selectedTabIndex) {
                    CalculatorView(onPressOperationButton: onPressOperationButton)
                        .tag(0)
                    ForEach(chunks.indices, id: \.self) { index in
                        HotkeysView(
                            onPressHotkey: onPressHotkey,
                            hotkeys: chunks[index]
                        )
                        .tag(index+1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            } else {
                ProgressView("Loading...").tint(.white).frame(maxWidth: .infinity)
            }
        }
        .frame(height: 60)
        .padding(.bottom, 10)
        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(.yellow), alignment: .bottom)
    }
}

struct SliderPad_Previews: PreviewProvider {
    static var previews: some View {
        SliderPad(
            onPressOperationButton: {x in},
            onPressHotkey: { x, y in },
            homeVM: MockHomeViewModel()
        )
    }
}
