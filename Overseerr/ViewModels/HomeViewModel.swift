import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var upcomingMovies: [Movie] = []
    @Published var recentMedia: [Media] = []
    @Published var currentUser: User?
    @Published var errorMessage: String?
    
    private let mediaRepository: MediaRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let authService: AuthServiceProtocol
    
    init(mediaRepository: MediaRepositoryProtocol, userRepository: UserRepositoryProtocol, authService: AuthServiceProtocol) {
        self.mediaRepository = mediaRepository
        self.userRepository = userRepository
        self.authService = authService
    }
    
    func loadData() async {
        do {
            // Parallel fetching
            async let movies = mediaRepository.getUpcomingMovies()
            async let media = mediaRepository.getTrending(page: 1)
            async let user = userRepository.getCurrentUser()
            
            self.upcomingMovies = try await movies
            self.recentMedia = try await media
            self.currentUser = try await user
        } catch {
            print("Error loading data: \(error)")
            self.errorMessage = error.localizedDescription
        }
    }
    
    func logout() async {
        do {
            try await authService.logout()
            // Clear local state after logout
            self.currentUser = nil
            self.upcomingMovies = []
            self.recentMedia = []
        } catch {
            print("Logout failed: \(error)")
            self.errorMessage = "Logout failed. Please try again."
        }
    }
}

