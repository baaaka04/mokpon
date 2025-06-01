import Foundation

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var authProviders: [AuthProviderOption] = []
    @Published private(set) var user: DBUser? = nil
    
    @Published var email = ""
    @Published var password = ""
    @Published var isSignedIn: Bool = false

    let authManager: AuthenticationManager
    let userManager: UserManager
    let directoriesManager: DirectoriesManager
    let amountManager: AmountManager

    init(appContext: AppContext) {
        self.authManager = appContext.authManager
        self.userManager = appContext.userManager
        self.directoriesManager = appContext.directoriesManager
        self.amountManager = appContext.amountManager
    }

    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }

        // Create user
        let authDataResult = try await authManager.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult)
        self.user = user
        try await userManager.createNewUser(user: user)

        // Create user amounts
        try await createAmounts(userId: user.userId)

        self.isSignedIn = true
    }
        
    func signOut() throws {
        try authManager.signOut()
        self.isSignedIn = false
    }
    
    func resetPassword() async throws {
        let authUser = try authManager.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await authManager.resetPassword(email: email)
    }
    
    func loadAuthProviders() {
        if let providers = try? authManager.getProviders() {
            authProviders = providers
        }
    }

    func loadAuthUser() async throws {
        let authDataResult = try authManager.getAuthenticatedUser()
        self.user = try await userManager.getUser(userId: authDataResult.uid)
    }

    func getAuthenticatedUser() throws -> AuthDataResultModel {
        return try authManager.getAuthenticatedUser()
    }

    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await authManager.linkGoogle(tokens: tokens)
        self.user = try await userManager.getUser(userId: authDataResult.uid)
    }

    func linkEmailAccount() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        let authDataResult = try await authManager.linkEmail(email: email, password: password)
        self.user = try await userManager.getUser(userId: authDataResult.uid)
    }

    func deleteUser() async throws {
        try await authManager.deleteUser()
        self.isSignedIn = false
    }

    private func createAmounts(userId: String) async throws {
        guard let currencies: [Currency] = directoriesManager.currencies else {
            throw AppError.currency
        }
        try await amountManager.createAmounts(userId: userId, currencies: currencies)
    }

}

//MARK: Signing in
extension AuthViewModel {
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        try await authManager.signInUser(email: email, password: password)
        self.isSignedIn = true
    }
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await authManager.signInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authDataResult, name: tokens.name, imageUrl: tokens.imageURL)
        do {
            self.user = try await userManager.getUser(userId: user.userId)
        } catch {
            try await userManager.createNewUser(user: user)
            try await createAmounts(userId: user.userId)
        }
        self.isSignedIn = true
    }
    
    func signInAnonymous() async throws {
        let authDataResult = try await authManager.signInAnonymous()
        let user = DBUser(auth: authDataResult)
        do {
            self.user = try await userManager.getUser(userId: user.userId)
        } catch {
            try await userManager.createNewUser(user: user)
            try await createAmounts(userId: user.userId)
        }
        self.isSignedIn = true
    }
    
}
