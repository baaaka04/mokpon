import Foundation

@MainActor
final class SettingsViewModel : ObservableObject {
    
    @Published var authProviders : [AuthProviderOption] = []
    @Published private(set) var user : DBUser? = nil
    
    @Published var email = ""
    @Published var password = ""

    func signUp () async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signIn () async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
    
    func signOut () throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword () async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func loadAuthProviders () {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    func loadAuthUser () async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func linkGoogleAccount () async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    func linkEmailAccount () async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        let authDataResult = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    func deleteUser () async throws {
        try await AuthenticationManager.shared.deleteUser()
    }
    
}
