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
    
    init(mediaRepository: MediaRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.mediaRepository = mediaRepository
        self.userRepository = userRepository
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
}
