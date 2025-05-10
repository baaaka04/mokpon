import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct AuthenticationView: View {

    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundCloud(posX: 230, posY: 740, width: 600, height: 450)

                VStack (spacing: 15) {

                    Image("AuthLogo")
                    Spacer()
                    NavigationLink {
                        SignInEmailView()
                    } label: {
                        Text("Sign In with Email").gradient()
                    }

                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                        Task {
                            do {
                                try await authViewModel.signInGoogle()
                            } catch { print(error) }
                        }

                    }
                    Text("Skip")
                        .padding()
                        .foregroundColor(Color.accentColor)
                        .onTapGesture {
                            Task {
                                do {
                                    try await authViewModel.signInAnonymous()
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
    struct Preview: View {
        @StateObject private var authViewModel = AuthViewModel(appContext: AppContext())

        var body: some View {
            AuthenticationView()
                .environmentObject(authViewModel)
        }
    }

    static var previews: some View {
        Preview()
    }
}
