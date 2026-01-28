import SwiftUI

struct HotkeysView: View {
        
    let onPressHotkey: @MainActor(_ category: Category, _ subcategory: String) -> Void
    var hotkeys : [Hotkey]

    let HTcolumns: [GridItem] = [
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
    ]

    var body: some View {
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
    }
}

struct HotkeysView_Previews: PreviewProvider {
    static var previews: some View {
        HotkeysView(onPressHotkey: {s,y in return}, hotkeys: [])
            .frame(maxHeight: .infinity)
            .background(.black)
    }
}
