import Foundation
import Combine

protocol AuthServiceProtocol {
    var isAuthenticated: Bool { get }
    var isAuthenticatedPublisher: Published<Bool>.Publisher { get }
    var currentUser: User? { get }
    
    func login(email: String, password: String) async throws
    func logout() async throws
    func checkAuth() async throws
    
    // Plex
    func startPlexLogin() async throws -> URL
}

class AuthService: AuthServiceProtocol, ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    @Published var plexPin: PlexPinResponse? // Store current PIN flow state
    
    var isAuthenticatedPublisher: Published<Bool>.Publisher { $isAuthenticated }
    
    // Persistent client ID should be stored in UserDefaults, generating temp for now if not present
    private let clientIdentifier: String = {
        if let stored = UserDefaults.standard.string(forKey: "plex_client_id") {
            return stored
        }
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: "plex_client_id")
        return newID
    }()
    
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
            }
        } catch {
            Logger.auth("Login failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func logout() async throws {
        Logger.auth("Logging out")
        let endpoint = Endpoint(path: "/auth/logout", method: .post)
        // Attempt server logout, but proceed to local logout regardless of error
        try? await networkService.request(endpoint)
        
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

    
    // MARK: - Plex Authentication
    
    func startPlexLogin() async throws -> URL {
        Logger.auth("Starting Plex Login Flow")
        let pinParams: [String: String] = [
            "strong": "true",
            "X-Plex-Product": "Overseerr iOS",
            "X-Plex-Client-Identifier": clientIdentifier,
            "X-Plex-Device": "iPhone",
            "X-Plex-Device-Name": "Overseerr iOS Client",
            "X-Plex-Platform": "iOS",
            "X-Plex-Version": "1.0"
        ]
        
        let queryItems = pinParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        let endpoint = Endpoint(
            path: "/api/v2/pins",
            method: .post,
            queryItems: queryItems,
            absoluteURL: URL(string: "https://plex.tv")
        )
        
        let pinResponse: PlexPinResponse = try await networkService.request(endpoint)
        
        await MainActor.run {
            self.plexPin = pinResponse
        }
        
        guard var components = URLComponents(string: "https://app.plex.tv/auth") else {
            throw NetworkError.unknown
        }
        
        components.fragment = "?clientID=\(clientIdentifier)&code=\(pinResponse.code)&context[device][product]=Overseerr iOS"
        
        guard let url = components.url else {
            throw NetworkError.unknown
        }
        
        Logger.auth("Plex PIN received: \(pinResponse.code). URL: \(url.absoluteString)")
        
        // Start polling in background
        Task {
            try? await pollForPlexToken(pin: pinResponse)
        }
        
        return url
    }
    
    // MARK: - Plex PIN Polling
    private func pollForPlexToken(pin: PlexPinResponse) async throws {
        let maxAttempts = 60 // 1 minute roughly if 1s sleep
        
        for _ in 0..<maxAttempts {
            try await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1 second
            
            if await checkPlexPinStatus(pinId: pin.id, code: pin.code) {
                return
            }
        }
        Logger.error("Plex PIN polling timed out")
    }
    
    private func checkPlexPinStatus(pinId: Int, code: String) async -> Bool {
        let endpoint = Endpoint(
            path: "/api/v2/pins/\(pinId)",
            method: .get,
            queryItems: [
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "X-Plex-Client-Identifier", value: clientIdentifier)
            ],
            absoluteURL: URL(string: "https://plex.tv")
        )
        
        do {
            let response: PlexPinResponse = try await networkService.request(endpoint)
            if let token = response.authToken {
                Logger.success("Plex Auth Token received!")
                try await completePlexLogin(with: token)
                return true
            }
        } catch {
            Logger.warning("Checking PIN status failed: \(error)")
        }
        return false
    }

    // Completes Plex login by exchanging the Plex token with your backend.
    private func completePlexLogin(with plexToken: String) async throws {
        // Adjust this endpoint to match your server's expected route for Plex auth completion
        let endpoint = Endpoint(
            path: "/auth/plex",
            method: .post,
            body: [
                "authToken": plexToken,
                "clientIdentifier": clientIdentifier
            ]
        )

        let user: User = try await networkService.request(endpoint)
        await MainActor.run {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
}

struct PlexPinResponse: Decodable, Sendable {
    let id: Int
    let code: String
    let url: String? // Some endpoints return it, v2 usually doesn't
    let authToken: String?
    // Add other fields if necessary
}
