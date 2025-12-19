import Foundation

protocol AppContainerProtocol {
    var networkService: NetworkServiceProtocol { get }
    
    func makeUserRepository() -> UserRepositoryProtocol
    func makeMediaRepository() -> MediaRepositoryProtocol
}

class AppContainer: AppContainerProtocol {
    let networkService: NetworkServiceProtocol
    
    init() {
        // Configuration should eventually come from UserSettings or Environment
        let baseURL = URL(string: "http://localhost:5055/api/v1")! 
        // For development, hardcoded local URL. In production, this would be dynamic.
        
        // TODO: Load API Key from Keychain
        let apiKey = "API_KEY_PLACEHOLDER"
        
        self.networkService = NetworkService(baseURL: baseURL, apiKey: apiKey)
    }
    
    func makeUserRepository() -> UserRepositoryProtocol {
        return UserRepository(networkService: networkService)
    }
    
    func makeMediaRepository() -> MediaRepositoryProtocol {
        return MediaRepository(networkService: networkService)
    }
}
