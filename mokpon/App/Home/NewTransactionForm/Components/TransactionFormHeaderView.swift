import SwiftUI


struct TransactionFormHeaderView: View {
    let onDismiss: () -> Void
    let onExchange: () -> Void

    var body: some View {
        HStack {
            Button(action: onDismiss) {
                Label(title: { Text("") }, icon: { Image(systemName: "xmark") })
            }
            Spacer()
            Button(action: onExchange) {
                Label(title: { Text("Exchange") }, icon: { Image(systemName: "arrow.triangle.2.circlepath") })
            }
        }
        .font(.custom("DMSans-Regular", size: 14))
        .foregroundColor(.yellow)
        .padding(.horizontal, 10)
    }
}


#Preview {
    TransactionFormHeaderView(
        onDismiss: { print("onDismiss") },
        onExchange: { print("onExchange") }
    )
}
