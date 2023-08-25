import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct AuthenticationView: View {
    
    @StateObject private var viewModel = AutheticationViewModel()
    @Binding var showSignInView : Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Button {
                    Task {
                        do {
                            try await viewModel.signInAnonymous()
                            showSignInView = false
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Sign In Anonymously")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.orange)
                        .cornerRadius(10)
                }

                NavigationLink {
                    SignInEmailView(showSignInView: $showSignInView)
                } label: {
                    Text("Sign In with Email")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .cornerRadius(10)
                }
                
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                    Task {
                        do {
                            try await viewModel.signInGoogle()
                            showSignInView = false
                        } catch {
                            print(error)
                        }
                    }
                }
                
            }
            .padding()
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(false))
        }
    }
}
