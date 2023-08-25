import SwiftUI

struct SignInEmailView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
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
                Text("Sign In")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .task {
            try? await viewModel.loadAuthUser()
        }
    }
}

struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        SignInEmailView(showSignInView: .constant(false))
    }
}
