import SwiftUI

struct HotkeysView: View {
    
    @EnvironmentObject var directiriesVM : DirectoriesManager
    
    let onPressHotkey: @MainActor(_ category: Category, _ subcategory: String) -> Void
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
            if let hotkeys, hotkeys[0].count != 0 {
                LazyVGrid(columns: HTcolumns, alignment: .center, spacing: 5) {
                    ForEach(hotkeys, id: \.self) { item in
                        Button(
                            action: {
                                if let category = directiriesVM.getCategory(byName: item[0]) {
                                    onPressHotkey(category, item[1])}
                            },
                            label: { Text(item[1])
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
            await fetchHotkeys()
        }
    }
}

struct HotkeysView_Previews: PreviewProvider {
    static var previews: some View {
        HotkeysView(onPressHotkey: {s,y in return}, hotkeys: [["питание","здоровая пища","опер"],["развлечения","прочее","опер"],["питание","всячина","опер"],["прочее","ат баши","опер"],["питание","кафе","опер"],["транспорт","такси","опер"],["транспорт","автобус","опер"],["ЖКХ","жкх","опер"]], fetchHotkeys: {})
            .frame(maxHeight: .infinity)
            .background(.black)
    }
}
