import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    @StateObject var viewModel: RootTabViewModel

    var body: some View {

        Group {
            if viewModel.isLoading {
                loadingView
            } else {
                mainView
            }
        }
        .onAppear {
            viewModel.loadRequirements()
        }
    }

    private var mainView: some View {
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

    private var loadingView: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainBackground)
        .foregroundStyle(.accent)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(viewModel: RootTabViewModel())
    }
}
