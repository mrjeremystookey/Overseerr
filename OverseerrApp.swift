import SwiftUI

@main
struct OverseerrApp: App {
    // Initialize the container once
    let container = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            // Inject dependencies into ContentView or a RootView
            // For now, we manually construct the VM for ContentView, 
            // or we pass the container down via Environment for deeper views.
            // Let's pass the container via EnvironmentObject or just closure injection.
            ContentView(viewModel: HomeViewModel(
                mediaRepository: container.makeMediaRepository(),
                userRepository: container.makeUserRepository()
            ))
        }
    }
}
