import Foundation

protocol UserRepositoryProtocol {
    func getCurrentUser() async throws -> User
    func getAllUsers() async throws -> [User] // Simplified return for now
}

class UserRepository: UserRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getCurrentUser() async throws -> User {
        let endpoint = Endpoint(path: "/auth/me")
        return try await networkService.request(endpoint)
    }
    
    func getAllUsers() async throws -> [User] {
        let endpoint = Endpoint(path: "/user", queryItems: [URLQueryItem(name: "take", value: "100")])
        let response: UserListResponse = try await networkService.request(endpoint)
        return response.results
    }
}

// Temporary helper struct for list response
struct UserListResponse: Decodable {
    let results: [User]
}
