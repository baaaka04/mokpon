import SwiftUI

struct TransactionView : View {
    
    let trans : Transaction
    var isLast : Bool
    var isLoading : Bool
    
    var body: some View {
        HStack (alignment: .center) {
            Image(systemName: categories[trans.category] ?? "questionmark")
                .frame(width: 50, height: 50)
                .background(.gray.opacity(0.4))
                .clipShape(Circle())
            VStack (alignment: .leading) {
                Text(String(trans.subCategory))
                Text(trans.date.formatted(.dateTime.day().month().year())).font(.caption)
            }
            Spacer()
            
            VStack{
                if self.isLast {
                    Text("₽\(trans.sum)")
                        .onAppear {
                            //isLoading = true - добавить в функцию пагинации
                            isLoading ? print("load data") : print("loading. pls wait")
                            //isLoading = false - добавить в функцию пагинации
                        }
                } else {
                    Text("₽\(trans.sum)")
                }
            }
            .frame(width: 90, height: 44)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(white: 0.3), lineWidth: 1)
            )
        }
        .padding()
//        .frame(width: 350, height: 80)
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("MainBackgroundColor"))
        .cornerRadius(20)
        .ignoresSafeArea()
    }
}

struct Transaction_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView(trans: Transaction(category: "category", subCategory: "subCategory", type: .expense, date: .now, sum: 2090), isLast: false, isLoading: false)
            .font(.custom("DMSans-Regular", size: 13))
            .foregroundColor(.white)
    }
}
