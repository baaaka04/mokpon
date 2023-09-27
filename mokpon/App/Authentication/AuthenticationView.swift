import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct AuthenticationView: View {
    
    @StateObject private var viewModel: AutheticationViewModel
    @Binding var showSignInView : Bool
    
    let authManager: AuthenticationManager
    let userManager: UserManager
    
    init(authManager: AuthenticationManager, userManager: UserManager, showSignInView: Binding<Bool>) {
        self.authManager = authManager
        self.userManager = userManager
        _viewModel = StateObject(wrappedValue: AutheticationViewModel(authManager: authManager, userManager: userManager))
        self._showSignInView = showSignInView
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundCloud(posX: 230, posY: 740, width: 600, height: 450)
                
                VStack (spacing: 15) {
                    
                    Image("AuthLogo")
                    Spacer()
                    NavigationLink {
                        SignInEmailView(authManager: authManager, userManager: userManager, showSignInView: $showSignInView)
                    } label: {
                        Text("Sign In with Email").gradient()
                    }
                    
                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                        Task {
                            do {
                                try await viewModel.signInGoogle()
                                showSignInView = false
                            } catch { print(error) }
                        }
                        
                    }
                    Text("Skip")
                        .padding()
                        .foregroundColor(Color.accentColor)
                        .onTapGesture {
                            Task {
                                do {
                                    try await viewModel.signInAnonymous()
                                    showSignInView = false
                                } catch { print(error) }
                            }
                        }
                }
                .frame(maxWidth: 250)
            }
            .background(Color.bg_main.ignoresSafeArea())
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(authManager: AuthenticationManager(), userManager: UserManager(), showSignInView: .constant(false))
        }
    }
}
