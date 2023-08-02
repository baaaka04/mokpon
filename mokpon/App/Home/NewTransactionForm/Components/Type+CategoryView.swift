import SwiftUI


struct Type_CategoryView: View {
    
    @Binding var selection: String?
    @Binding var type: ExpensesType
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
    ]
    
    var body: some View {
        ZStack{
//Categories
            Menu {
                ForEach(Array(categories.keys), id: \.self) { cat in
                    Button {selection = cat}
                label: {
                    Label(title: {Text(cat)}, icon: {Image(systemName: categories[cat] ?? "questionmark")})}
                }
                //Extra button for investment type of expenses
                Button {
                    selection = "прочее"
                    type = .invest
                } label: {Label("инвест", systemImage: "i.circle")}
                
            } label: {
                Label(
                    title: {Text("\(selection ?? "Category")")},
                    icon: {Image(systemName: "chevron.down")}
                )
                .font(.custom("DMSans-Regular", size: 10))
                .padding(15)
                .padding(.horizontal, 30)
                .background(Image("Trapeze"))
            }
            .offset(y:35)
            
//Type: Income/Expense
            LazyVGrid (columns: columns) {
                Button("INCOME") {
                    type = .income
                }
                .frame(height: 47)
                .frame(maxWidth: .infinity)
                .background(type == .income
                            ? Color.expense_type.opacity(0.5)
                            : Color.white.opacity(0)
                )
                
                Button("EXPENSE") {
                    type = .expense
                }
                .frame(height: 47)
                .frame(maxWidth: .infinity)
                .background(type == .expense
                            ? Color.expense_type.opacity(0.5)
                            : Color.white.opacity(0)
                )
            }
            .background(
                LinearGradient(
                    gradient:
                        Gradient(colors: [
                            Color.addbutton_main,
                            Color.addbutton_secondary,
                        ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}

struct Type_CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        Type_CategoryView(
            selection: .constant(nil),
            type: .constant(ExpensesType.expense)
        )
    }
}
