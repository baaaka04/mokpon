import SwiftUI

struct SubcategoryInput: View {
    
    @Binding var subcategory : String
    
    var body: some View {
        // Using ZStack to color the placeholder
        ZStack(alignment: .leading) {
            if subcategory.isEmpty {
                Text("Add Description")
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 10)
            }
            TextField("", text: $subcategory )
                .onChange(of: subcategory) { _ in
                    let newText = String(subcategory.prefix(35))
                    subcategory = newText
                }
                .padding(4)
                .overlay(Rectangle()
                    .frame(width: nil, height: 1, alignment: .bottom)
                    .foregroundColor(.yellow), alignment: .bottom)
                .accentColor(.yellow)
        }
    }
}

struct SubcategoryInput_Previews: PreviewProvider {
    static var previews: some View {
        SubcategoryInput(subcategory: .constant(""))
    }
}
