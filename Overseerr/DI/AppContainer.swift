import Foundation

protocol AppContainerProtocol {
    var networkService: NetworkServiceProtocol { get }
    var authService: AuthServiceProtocol { get }
    
    func makeUserRepository() -> UserRepositoryProtocol
    func makeMediaRepository() -> MediaRepositoryProtocol
    func makeRequestRepository() -> RequestRepositoryProtocol
    func makeLoginViewModel() -> LoginViewModel
    func makeRequestListViewModel() -> RequestListViewModel
}

class AppContainer: AppContainerProtocol {
    let networkService: NetworkServiceProtocol
    let authService: AuthServiceProtocol
    
    init() {
        // Configuration should eventually come from UserSettings or Environment
        let baseURL = URL(string: "http://localhost:5055/api/v1")! 
        // For development, hardcoded local URL. In production, this would be dynamic.
        
        // TODO: Load API Key from Keychain if available
        let apiKey: String? = nil
        
        self.networkService = NetworkService(baseURL: baseURL, apiKey: apiKey)
        self.authService = AuthService(networkService: networkService)
    }
    
    func makeUserRepository() -> UserRepositoryProtocol {
        return UserRepository(networkService: networkService)
    }
    
    func makeMediaRepository() -> MediaRepositoryProtocol {
        return MediaRepository(networkService: networkService)
    }
    
    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(authService: authService)
    }
    
    func makeRequestRepository() -> RequestRepositoryProtocol {
        return RequestRepository(networkService: networkService)
    }
    
    func makeRequestListViewModel() -> RequestListViewModel {
        return RequestListViewModel(requestRepository: makeRequestRepository())
    }
}
