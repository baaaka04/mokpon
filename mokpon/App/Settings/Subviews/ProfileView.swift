import SwiftUI

struct ProfileView: View {
    var user: DBUser? = nil
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Group {
                    if let imageUrl = user?.imageUrl,
                       let url = URL(string: imageUrl) {
                        AsyncImage(url: url)
                    } else {
                        Image(systemName: "person")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.bg_main)
                    }
                }
                .padding()
                .frame(width: 80, height: 80)
                .background(Color.white.opacity(0.7))
                .cornerRadius(100)

                VStack(alignment: .leading) {
                    Text("Name: \(user?.name ?? "not found")")
                    Text("Email: \(user?.email ?? "not found")")
                }

                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .font(.custom("DMSans-Regular", size: 16))
        .padding(10)
        .background(.white.opacity(0.1))
        .cornerRadius(20)
    }

}

struct ProfileView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var viewModel = RootTabViewModel()

        var body: some View {
            ProfileView()
                .environmentObject(viewModel)
                .background(Color.bg_main)
                .preferredColorScheme(.dark)
        }
    }

    static var previews: some View {
        Preview()
    }
}
