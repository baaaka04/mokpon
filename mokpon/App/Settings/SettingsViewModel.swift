import Foundation

@MainActor
final class SettingsViewModel : ObservableObject {
    
    @Published var authProviders : [AuthProviderOption] = []
    @Published private(set) var user : DBUser? = nil
    
    @Published var email = ""
    @Published var password = ""
    
    let authManager: AuthenticationManager
    let userManager: UserManager
    
    init(authManager: AuthenticationManager, userManager: UserManager) {
        self.authManager = authManager
        self.userManager = userManager
    }

    func signUp () async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        let authDataResult = try await authManager.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult)
        try await userManager.createNewUser(user: user)
    }
    
    func signIn () async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        try await authManager.signInUser(email: email, password: password)
    }
    
    func signOut () throws {
        try authManager.signOut()
    }
    
    func resetPassword () async throws {
        let authUser = try authManager.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await authManager.resetPassword(email: email)
    }
    
    func loadAuthProviders () {
        if let providers = try? authManager.getProviders() {
            authProviders = providers
        }
    }
    func loadAuthUser () async throws {
        let authDataResult = try authManager.getAuthenticatedUser()
        self.user = try await userManager.getUser(userId: authDataResult.uid)
    }
    
    func linkGoogleAccount () async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await authManager.linkGoogle(tokens: tokens)
        self.user = try await userManager.getUser(userId: authDataResult.uid)
    }
    func linkEmailAccount () async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        let authDataResult = try await authManager.linkEmail(email: email, password: password)
        self.user = try await userManager.getUser(userId: authDataResult.uid)
    }
    func deleteUser () async throws {
        try await authManager.deleteUser()
    }
    
}
