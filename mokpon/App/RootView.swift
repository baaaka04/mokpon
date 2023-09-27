import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    let authManager = AuthenticationManager()
    let userManager = UserManager()
    let directoriesManager = DirectoriesManager(completion: {})
        
    var body: some View {
        ZStack {
            if !showSignInView {
                ContentView(authManager: authManager, userManager: userManager, showSignInView: $showSignInView, directoriesManager: directoriesManager)
            }
        }
        .onAppear {
            let authUser = try? authManager.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            AuthenticationView(authManager: authManager, userManager: userManager, showSignInView: $showSignInView)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
