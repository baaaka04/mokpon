import SwiftUI

struct ProfileView: View {
    
    var user : DBUser? = nil
    
    var body: some View {
        VStack {
            HStack (spacing: 20) {
                Image(systemName: "person")
                    .resizable()
                    .padding()
                    .frame(maxWidth: 80, maxHeight: 80)
                    .foregroundColor(.bg_main)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(100)
                Text("Email: \(user?.email ?? "not found")")
                Spacer()
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(.white.opacity(0.1))
        .cornerRadius(20)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSingInView: .constant(false), viewModel: SettingsViewModel(appContext: AppContext()))
            .background(Color.bg_main)
            .environmentObject(RootTabViewModel(appContext: AppContext()))
            .preferredColorScheme(.dark)
    }
}
