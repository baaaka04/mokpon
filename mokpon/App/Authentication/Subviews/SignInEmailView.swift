import SwiftUI

struct SignInEmailView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            BackgroundCloud(posX: 230, posY: 740, width: 600, height: 450)
            VStack (spacing: 20) {
                TextField("Email...", text: $authViewModel.email)
                    .padding()
                    .background(.gray.opacity(0.4))
                    .cornerRadius(10)
                SecureField("Password...", text: $authViewModel.password)
                    .padding()
                    .background(.gray.opacity(0.4))
                    .cornerRadius(10)
                Button {
                    Task {
                        if let user = authViewModel.user, user.isAnonymous ?? false {
                            do {
                                try await authViewModel.linkEmailAccount()
                                print("EMAIL LINKED")
                                presentationMode.wrappedValue.dismiss()
                                return
                            } catch {
                                print(error)
                            }
                        } else {
                            do {
                                try await authViewModel.signUp()
                                return
                            } catch {
                                print(error)
                            }
                            do {
                                try await authViewModel.signIn()
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
                try? await authViewModel.loadAuthUser()
            }
        }
        .background(Color.bg_main.ignoresSafeArea())
    }
}

struct SignInEmailView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var authViewModel = AuthViewModel(appContext: AppContext())

        var body: some View {
            SignInEmailView()
                .environmentObject(authViewModel)
        }
    }

    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
