import SwiftUI

struct ExpenseView : View {
    
    var expenseData : ExpenseData
    
    var body: some View {
        
        HStack (alignment: .center) {
            Image(systemName: categories[expenseData.title] ?? "questionmark")
                .frame(width: 50, height: 50)
                .background(.gray.opacity(0.4))
                .clipShape(Circle())
            VStack (alignment: .leading) {
                Text(String(expenseData.title))
                Text(expenseData.subtitle).font(.caption)
            }
            Spacer()
            
            VStack{
                Text(expenseData.number)
            }
            .frame(width: 90, height: 44)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(white: 0.2), lineWidth: 1)
            )
        }
        .padding()
        .frame(width: 350, height: 80)
        .background(Color("MainBackgroundColor"))
        .cornerRadius(20)
    }
}

struct ExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseView(expenseData: ExpenseData(title: "food", subtitle: "02-2022", number: "\(3232.formatted())"))            .font(.custom("DMSans-Regular", size: 13))
            .foregroundColor(.white)
    }
}
