import SwiftUI

struct SignInEmailView: View {
    
    @StateObject private var viewModel: SettingsViewModel
    @Binding var showSignInView: Bool
    
    init(authManager: AuthenticationManager, userManager: UserManager, showSignInView: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(authManager: authManager, userManager: userManager))
        _showSignInView = showSignInView
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            BackgroundCloud(posX: 230, posY: 740, width: 600, height: 450)
            VStack (spacing: 20) {
                TextField("Email...", text: $viewModel.email)
                    .padding()
                    .background(.gray.opacity(0.4))
                    .cornerRadius(10)
                SecureField("Password...", text: $viewModel.password)
                    .padding()
                    .background(.gray.opacity(0.4))
                    .cornerRadius(10)
                Button {
                    Task {
                        if let user = viewModel.user, user.isAnonymous ?? false {
                            do {
                                try await viewModel.linkEmailAccount()
                                print("EMAIL LINKED")
                                presentationMode.wrappedValue.dismiss()
                                return
                            } catch {
                                print(error)
                            }
                        } else {
                            do {
                                try await viewModel.signUp()
                                showSignInView = false
                                return
                            } catch {
                                print(error)
                            }
                            do {
                                try await viewModel.signIn()
                                showSignInView = false
                                return
                            } catch {
                                print(error)
                            }
                        }
                    }
                } label: {
                    Text("Sign In").gradient()
                }
                Spacer()
            }
            .navigationTitle("Signing in with Email")
            .padding()
            .task {
                try? await viewModel.loadAuthUser()
            }
        }
        .background(Color.bg_main.ignoresSafeArea())
    }
}

struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        SignInEmailView(authManager: AuthenticationManager(), userManager:UserManager(), showSignInView: .constant(false))
    }
}
