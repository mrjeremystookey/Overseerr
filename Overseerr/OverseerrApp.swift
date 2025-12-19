import SwiftUI

@main
struct OverseerrApp: App {
    // Initialize the container once
    let container = AppContainer()
    
    // Simple state to track auth status, observed from the service
    @State private var isAuthenticated = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isAuthenticated {
                    ContentView(
                        homeViewModel: HomeViewModel(
                            mediaRepository: container.makeMediaRepository(),
                            userRepository: container.makeUserRepository(),
                            authService: container.authService
                        ),
                        requestListViewModel: container.makeRequestListViewModel()
                    )
                    .transition(.opacity)
                } else {
                    LoginView(viewModel: container.makeLoginViewModel())
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: isAuthenticated)
            .onReceive(container.authService.isAuthenticatedPublisher) { authState in
                self.isAuthenticated = authState
            }
            .onAppear {
                // Check if we have a valid session on launch
                Task {
                    try? await container.authService.checkAuth()
                }
            }
        }
    }
}
