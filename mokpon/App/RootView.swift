import SwiftUI

struct RootView: View {

    @ObservedObject private var rootViewModel: RootTabViewModel
    @ObservedObject private var authViewModel: AuthViewModel

    init(viewModel: RootTabViewModel) {
        _rootViewModel = ObservedObject(wrappedValue: viewModel)
        _authViewModel = ObservedObject(wrappedValue: viewModel.authViewModel)
    }

    var body: some View {
        Group {
            if rootViewModel.isLoading {
                loadingView
            } else {
                mainView
            }
        }
        .environmentObject(authViewModel)
        .onAppear {
            rootViewModel.loadRequirements()
        }
    }

    private var mainView: some View {
        ZStack {
            if authViewModel.isSignedIn {
                RootTabView()
                    .environmentObject(rootViewModel)
            }
        }
        .onAppear {
            let authUser = try? authViewModel.getAuthenticatedUser()
            self.authViewModel.isSignedIn = authUser != nil
        }
        /// Can't use $authViewModel.isSignedIn because of the naming
        .fullScreenCover(isPresented: Binding(
            get: { !authViewModel.isSignedIn },
            set: { authViewModel.isSignedIn = !$0 }
        )) {
            AuthenticationView()
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
