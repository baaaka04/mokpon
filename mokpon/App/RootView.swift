import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    @StateObject var viewModel: RootTabViewModel
        
    var body: some View {
        ZStack {
            if !showSignInView {
                RootTabView(showSignInView: $showSignInView, viewModel: viewModel)
            }
        }
        .onAppear {
            let authUser = try? viewModel.settingsViewModel.authManager.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            AuthenticationView(settingsViewModel: viewModel.settingsViewModel, showSignInView: $showSignInView)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(viewModel: RootTabViewModel(appContext: AppContext()))
    }
}
