import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSingInView : Bool
    @State private var showAlert : Bool = false
    
    var body: some View {
        VStack {
            ProfileView(user: viewModel.user)
            
            List {
                Button {
                    Task {
                        do {
                            try viewModel.signOut()
                            showSingInView = true
                        } catch {
                            print(error)
                        }
                    }
                    
                } label: {
                    Text("LogOut")
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
                
                if viewModel.authProviders.contains(.email) {
                    emailSection
                }
                
                if let user = viewModel.user, user.isAnonymous ?? false {
                    anonymousSection
                }
            }
        }
        .task {
            viewModel.loadAuthProviders()
            try? await viewModel.loadAuthUser()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSingInView: .constant(true))
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
            Button ("SignIn with Google") {
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
                SignInEmailView(showSignInView: .constant(false))
            } label: {
                Text("Sign In with Email")
            }
            
        } header: {
            Text("Create account")
        }
    }
}
