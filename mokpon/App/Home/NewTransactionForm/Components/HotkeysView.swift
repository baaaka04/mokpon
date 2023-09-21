import SwiftUI

struct HotkeysView: View {
        
    let onPressHotkey: @MainActor(_ category: Category, _ subcategory: String) -> Void
    var hotkeys : [Hotkey]?
    var fetchHotkeys : @MainActor() -> Void
    
    let HTcolumns: [GridItem] = [
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
    ]
    
    var body: some View {
        Group {
            if let hotkeys {
                LazyVGrid(columns: HTcolumns, alignment: .center, spacing: 5) {
                    ForEach(hotkeys, id: \.subcategory) { hk in
                        Button(
                            action: {
                                onPressHotkey(hk.category, hk.subcategory)
                            },
                            label: { Text(hk.subcategory)
                                    .frame(maxWidth: 50, maxHeight: 27)
                                    .font(.custom("DMSans-Regular", size: 10))
                                    .lineLimit(2)
                            }
                        )
                    }
                }
            } else {
                ProgressView("Loading...").tint(.white).frame(maxWidth: .infinity)
            }
        }
        .task {
            fetchHotkeys()
        }
    }
}

struct HotkeysView_Previews: PreviewProvider {
    static var previews: some View {
        HotkeysView(onPressHotkey: {s,y in return}, hotkeys: [], fetchHotkeys: {})
            .frame(maxHeight: .infinity)
            .background(.black)
    }
}
