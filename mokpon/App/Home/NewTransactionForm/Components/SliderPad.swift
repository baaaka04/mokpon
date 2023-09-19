import SwiftUI

struct SliderPad: View {
    
    @State private var selectedTabIndex = 1
    let onPressOperationButton : @MainActor(_ key: String) -> Void
    let onPressHotkey: @MainActor(_ category: Category, _ subcategory: String) -> Void
    var hotkeys : [Hotkey]?
    var fetchHotkeys : @MainActor() -> Void
    
    private func switchTabToCalculator () {
        if selectedTabIndex == 0 { withAnimation{ selectedTabIndex = 1 } }
    }
    private func switchTabToHotkeys () {
        if selectedTabIndex == 1 { withAnimation{ selectedTabIndex = 0 } }
    }
    
    var body: some View {
        VStack {
            TabView (selection: $selectedTabIndex) {
                CalculatorView(onPressOperationButton: onPressOperationButton)
                    .tag(0)
                HotkeysView(
                    onPressHotkey: onPressHotkey,
                    hotkeys: hotkeys,
                    fetchHotkeys: fetchHotkeys
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

struct SliderPad_Previews: PreviewProvider {
    static var previews: some View {
        SliderPad(onPressOperationButton: {x in}, onPressHotkey: { x, y in }, hotkeys: [], fetchHotkeys: {})
    }
}
