import Foundation
import Combine

protocol AuthServiceProtocol {
    var isAuthenticated: Bool { get }
    var isAuthenticatedPublisher: Published<Bool>.Publisher { get }
    var currentUser: User? { get }
    
    func login(email: String, password: String) async throws
    func logout() async throws
    func checkAuth() async throws
}

class AuthService: AuthServiceProtocol, ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    
    var isAuthenticatedPublisher: Published<Bool>.Publisher { $isAuthenticated }
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func login(email: String, password: String) async throws {
        Logger.auth("Attempting login for \(email)")
        let endpoint = Endpoint(
            path: "/auth/local",
            method: .post,
            body: ["email": email, "password": password]
        )
        
        do {
            let user: User = try await networkService.request(endpoint)
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                Logger.success("Login successful for \(user.email)")
            }
        } catch {
            Logger.auth("Login failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func logout() async throws {
        Logger.auth("Logging out")
        let endpoint = Endpoint(path: "/auth/logout", method: .post)
        try await networkService.request(endpoint)
        
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
            Logger.success("Logged out successfully")
        }
    }
    
    func checkAuth() async throws {
        // Logger.auth("Checking session state...") // Noisy loop check potentially?
        let endpoint = Endpoint(path: "/auth/me")
        do {
            let user: User = try await networkService.request(endpoint)
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                Logger.auth("Session Valid: \(user.email)")
            }
        } catch {
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
                Logger.auth("No active session")
            }
            throw error
        }
    }
}
