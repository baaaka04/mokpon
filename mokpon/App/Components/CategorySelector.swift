import SwiftUI


struct CategorySelector: View {
    @Binding var searchText: String
    @Binding var selectedScope: Category?
    var searchScopes: [Category]

    let updateTransactions: @MainActor() -> ()

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(searchScopes, id: \.self) { scope in
                    HStack{
                        Image(systemName: scope.icon)
                        Text(scope.name)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(selectedScope == scope ? Color.accentColor.opacity(0.3) : nil)
                    .foregroundColor(selectedScope == scope ? Color.white : Color.accentColor)
                    .clipShape(Capsule())
                    .customGlassEffect(in: Capsule())
                    .padding(.leading, scope == searchScopes.first ? 16 : 0)
                    .padding(.trailing, scope == searchScopes.last ? 16 : 0)
                    .onTapGesture {
                        selectedScope = selectedScope == scope ? nil : scope
                        updateTransactions()
                    }
                }
            }
        }
    }
}
