import SwiftUI

struct RootView: View {

    @ObservedObject private var rootViewModel: RootTabViewModel
    @ObservedObject private var authViewModel: AuthViewModel

    init(viewModel: RootTabViewModel) {
        _rootViewModel = ObservedObject(wrappedValue: viewModel)
        _authViewModel = ObservedObject(wrappedValue: viewModel.authViewModel)
    }

    var body: some View {
        ZStack {
            if authViewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if authViewModel.isSignedIn {
                RootTabView()
            } else {
                Text("Authorization error").frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            guard !authViewModel.isLoading else { return }
            authViewModel.isLoading = true
            let authUser = try? authViewModel.getAuthenticatedUser()
            self.authViewModel.isSignedIn = authUser != nil
            authViewModel.isLoading = false
        }
        /// Can't use $authViewModel.isSignedIn because of the naming
        .fullScreenCover(isPresented: Binding(
            get: { !authViewModel.isSignedIn },
            set: { authViewModel.isSignedIn = !$0 }
        )) {
            AuthenticationView()
        }
        .environmentObject(rootViewModel)
        .environmentObject(authViewModel)
    }
}

struct RootView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var viewModel = RootTabViewModel()

        var body: some View {
            RootView(viewModel: viewModel)
        }
    }

    static var previews: some View {
        Preview()
    }
}
