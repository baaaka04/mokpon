import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var authViewModel: AuthViewModel
    @AppStorage("mainCurrency") private var mainCurrency: String = "USD"
    @State private var showAlert: Bool = false

    var body: some View {
        VStack {
            Text("Settings")
                .font(.title3.width(.expanded))
                .foregroundColor(.white)
            ProfileView(user: authViewModel.user)
                .padding()
            List {
                Button {
                    Task {
                        do {
                            try authViewModel.signOut()
                            mainCurrency = "USD"
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
                                    try await authViewModel.deleteUser()
                                } catch {
                                    print(error)
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                if let currencies = authViewModel.directoriesManager.currencies {
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
                
                if authViewModel.authProviders.contains(.email) {
                    emailSection
                }
                
                if let user = authViewModel.user, user.isAnonymous ?? false {
                    anonymousSection
                }
            }
            .scrollContentBackground(.hidden)
        }
        .foregroundColor(.accentColor)
        .task {
            authViewModel.loadAuthProviders()
            try? await authViewModel.loadAuthUser()
        }
    }
}

extension SettingsView {
    
    private var emailSection: some View {
        Section {
            Button {
                Task {
                    do {
                        try await authViewModel.resetPassword()
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
                        try await authViewModel.linkGoogleAccount()
                        print("GGOGLE LINKED")
                    } catch {
                        print(error)
                    }
                }
            }
            NavigationLink {
                SignInEmailView()
            } label: {
                Text("Link Email")
            }
            
        } header: {
            Text("Create account")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var viewModel = RootTabViewModel()

        var body: some View {
            SettingsView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
        }
    }

    static var previews: some View {
        Preview()
    }
}
