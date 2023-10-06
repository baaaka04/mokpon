import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel : SettingsViewModel
    @EnvironmentObject private var rootViewModel : RootTabViewModel
    @AppStorage("mainCurrency") private var mainCurrency : String = "USD"
    @Binding var showSingInView : Bool
    @State private var showAlert : Bool = false
        
    init(showSingInView: Binding<Bool>, viewModel: SettingsViewModel) {
        _showSingInView = showSingInView
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.title3.width(.expanded))
                .foregroundColor(.white)
            ProfileView(user: viewModel.user)
                .padding()
            List {
                Button {
                    Task {
                        do {
                            try viewModel.signOut()
                            mainCurrency = "USD"
                            showSingInView = true
                        } catch {
                            print(error)
                        }
                    }
                    
                } label: {
                    Text("Logout")
                }
                Button (role: .destructive) {
                    showAlert = true
                } label: {
                    Text("Delete account")
                }
                .alert(isPresented:$showAlert) {
                    Alert(
                        title: Text("Are you sure you want to delete your account?"),
                        message: Text("There is no undo"),
                        primaryButton: .destructive(Text("Delete")) {
                            Task {
                                do {
                                    try await viewModel.deleteUser()
                                    showSingInView = true
                                } catch {
                                    print(error)
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                if let currencies = rootViewModel.currencies {
                    Section {
                        Picker(selection: $mainCurrency) {
                            ForEach(currencies, id: \.self) { cur in
                                Text(cur.name)
                                    .tag(cur.name)
                            }
                        } label: {
                            Text("Selected currency: ")
                        }
                        
                    } header: {
                        Text("Main currency")
                    }
                }
                
                if viewModel.authProviders.contains(.email) {
                    emailSection
                }
                
                if let user = viewModel.user, user.isAnonymous ?? false {
                    anonymousSection
                }
            }
            .scrollContentBackground(.hidden)
        }
        .foregroundColor(.accentColor)
        .task {
            viewModel.loadAuthProviders()
            try? await viewModel.loadAuthUser()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSingInView: .constant(false), viewModel: SettingsViewModel(appContext: AppContext()))
            .environmentObject(RootTabViewModel(appContext: AppContext()))
            .preferredColorScheme(.dark)
    }
}


extension SettingsView {
    
    private var emailSection: some View {
        Section {
            Button {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("PASSWORD RESET")
                    } catch {
                        print(error)
                    }
                }
                
            } label: {
                Text("Reset password")
            }
        } header: {
            Text("Email settings")
        }
    }
    
    private var anonymousSection: some View {
        
        Section {
            Button ("Link Google account") {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("GGOGLE LINKED")
                    } catch {
                        print(error)
                    }
                }
            }
            NavigationLink {
                SignInEmailView(viewModel: viewModel,showSignInView: .constant(false))
            } label: {
                Text("Link Email")
            }
            
        } header: {
            Text("Create account")
        }
    }
}
