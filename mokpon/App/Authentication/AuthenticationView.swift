import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct AuthenticationView: View {
    
    @StateObject private var settingsViewModel: SettingsViewModel
    @Binding var showSignInView : Bool

    init(settingsViewModel: SettingsViewModel, showSignInView: Binding<Bool> ) {
        _showSignInView = showSignInView
        _settingsViewModel = StateObject(wrappedValue:settingsViewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundCloud(posX: 230, posY: 740, width: 600, height: 450)
                
                VStack (spacing: 15) {
                    
                    Image("AuthLogo")
                    Spacer()
                    NavigationLink {
                        SignInEmailView(viewModel: settingsViewModel, showSignInView: $showSignInView)
                    } label: {
                        Text("Sign In with Email").gradient()
                    }
                    
                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                        Task {
                            do {
                                try await settingsViewModel.signInGoogle()
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
                                    try await settingsViewModel.signInAnonymous()
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
            AuthenticationView(settingsViewModel: SettingsViewModel(appContext: AppContext()), showSignInView: .constant(true))
        }
    }
}
