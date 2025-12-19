import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.login(email: email, password: password)
            // Navigation is handled by observing AuthService state in the parent/RootView
        } catch {
            if let networkError = error as? NetworkError, case .requestFailed(let statusCode) = networkError {
                if statusCode == 401 || statusCode == 403 {
                    errorMessage = "Invalid credentials."
                } else {
                    errorMessage = "Login failed. Server returned \(statusCode)."
                }
            } else {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    func loginWithPlex() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = try await authService.startPlexLogin()
            // The view will handle opening this URL if we pass it back or publish it.
            // For now, we returns it or assume the View triggers openURL from a binding?
            // Better: Published property.
            self.plexAuthURL = url
        } catch {
            errorMessage = "Failed to start Plex login: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @Published var plexAuthURL: URL?
}
