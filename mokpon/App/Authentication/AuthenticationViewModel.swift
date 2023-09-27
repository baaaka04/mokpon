import Foundation

@MainActor
final class AutheticationViewModel : ObservableObject {
    
    let authManager: AuthenticationManager
    let userManager: UserManager
    
    init(authManager: AuthenticationManager, userManager: UserManager) {
        self.authManager = authManager
        self.userManager = userManager
    }
    
    func signInGoogle () async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await authManager.signInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authDataResult)
        try await userManager.createNewUser(user: user)
    }
    
    func signInAnonymous() async throws {
        let authDataResult = try await authManager.signInAnonymous()
        let user = DBUser(auth: authDataResult)
        try await userManager.createNewUser(user: user)
    }
}
