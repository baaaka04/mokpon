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
                    .background(selectedScope == scope ? Color.accentColor : Color.gray.opacity(0.2))
                    .foregroundColor(selectedScope == scope ? Color.black : Color.accentColor)
                    .cornerRadius(8)
                    .onTapGesture {
                        selectedScope = selectedScope == scope ? nil : scope
                        updateTransactions()
                    }
                }
            }
        }
    }
}
