import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct AuthenticationView: View {
    
    @StateObject private var viewModel = AutheticationViewModel()
    @Binding var showSignInView : Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundCloud(posX: 230, posY: 740, width: 600, height: 450)
                
                VStack {
                    
                    Image("AuthLogo")
                    Spacer()
                    NavigationLink {
                        SignInEmailView(showSignInView: $showSignInView)
                    } label: {
                        Text("Sign In with Email")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient:
                                        Gradient(colors: [
                                            Color.addbutton_secondary,
                                            Color.addbutton_main,
                                        ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .strokeBorder(Color.white.opacity(0.5),lineWidth: 1)
                            )
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
            AuthenticationView(showSignInView: .constant(false))
        }
    }
}
