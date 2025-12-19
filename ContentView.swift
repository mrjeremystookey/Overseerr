import SwiftUI

struct ContentView: View {
    // We construct VMs via DI in the App entry, but for TabView 
    // we might need to access the container via Environment to create VMs on demand or pass them in.
    // For simplicity, let's pass the container or the VMs we need.
    // Ideally, we pass the Container to ContentView?
    
    // Refactoring to use EnvironmentObject for Container could be cleaner, 
    // but sticking to constructor injection for now.
    
    let homeViewModel: HomeViewModel
    let requestListViewModel: RequestListViewModel
    
    var body: some View {
        TabView {
            // Home Tab
            NavigationView {
                List {
                    if let user = homeViewModel.currentUser {
                        Section("User") {
                            Text("Logged in as: \(user.email)")
                        }
                    }
                    
                    Section("Upcoming Movies") {
                        ForEach(homeViewModel.upcomingMovies) { movie in
                            Text(movie.title)
                        }
                    }
                    
                    Section("Recent Media") {
                        ForEach(homeViewModel.recentMedia) { media in
                            Text("Media ID: \(media.id) - Status: \(media.status.description)")
                        }
                    }
                }
                .navigationTitle("Dashboard")
                .task {
                    await homeViewModel.loadData()
                }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            // Requests Tab (Admin)
            // We pass the RequestListView directly or wrapped
            // Note: RequestListView has its own NavigationView
            RequestListView(viewModel: requestListViewModel)
                .tabItem {
                    Label("Requests", systemImage: "tray.full")
                }
        }
    }
}
