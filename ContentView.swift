import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            List {
                if let user = viewModel.currentUser {
                    Section("User") {
                        Text("Logged in as: \(user.email)")
                    }
                }
                
                Section("Upcoming Movies") {
                    ForEach(viewModel.upcomingMovies) { movie in
                        Text(movie.title)
                    }
                }
                
                Section("Recent Media") {
                    ForEach(viewModel.recentMedia) { media in
                        Text("Media ID: \(media.id) - Status: \(media.status)")
                    }
                }
            }
            .navigationTitle("Overseerr")
            .task {
                await viewModel.loadData()
            }
        }
    }
}
