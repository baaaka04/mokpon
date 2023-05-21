import SwiftUI

struct HotkeysView: View {
    
    let onPressHotkey: (_ hotkey: [String]) -> Void
    var hotkeys : [[String]]?
    var fetchHotkeys : () async -> Void
    
    let HTcolumns: [GridItem] = [
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
    ]
    
    var body: some View {
        Group {
            if hotkeys?[0].count == 0 {
                ProgressView("Loading...").tint(.white).frame(maxWidth: .infinity)
            } else {
                LazyVGrid(columns: HTcolumns, alignment: .center, spacing: 5) {
                    ForEach(hotkeys!, id: \.self) { item in
                        Button(
                            action: {
                                onPressHotkey(item)
                            },
                            label: { Text(item[1])
                                    .frame(maxWidth: 50, maxHeight: 27)
                                    .font(.custom("DMSans-Regular", size: 10))
                                    .lineLimit(2)
                            }
                        )
                    }
                }
            }
        }
        .task {
            await fetchHotkeys()
        }
    }
}

struct HotkeysView_Previews: PreviewProvider {
    static var previews: some View {
        HotkeysView(onPressHotkey: {s in return}, hotkeys: [["питание","здоровая пища","опер"],["развлечения","прочее","опер"],["питание","всячина","опер"],["прочее","ат баши","опер"],["питание","кафе","опер"],["транспорт","такси","опер"],["транспорт","автобус","опер"],["ЖКХ","жкх","опер"]], fetchHotkeys: {})
            .frame(maxHeight: .infinity)
            .background(.black)
    }
}
