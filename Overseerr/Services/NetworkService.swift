import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) async throws -> T
    func request(_ endpoint: Endpoint) async throws -> Void
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]?
    let body: Data?
    
    init(path: String, method: HTTPMethod = .get, queryItems: [URLQueryItem]? = nil, body: Encodable? = nil) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        if let body = body {
            self.body = try? JSONEncoder().encode(body)
        } else {
            self.body = nil
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed
    case unknown
}

class NetworkService: NetworkServiceProtocol {
    private let baseURL: URL
    private let session: URLSession
    private var apiKey: String?
    
    init(baseURL: URL, apiKey: String? = nil, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.session = session
    }
    
    func setApiKey(_ key: String) {
        self.apiKey = key
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) async throws -> T {
        let request = try createRequest(from: endpoint)
        
        // Debug
        // print("Request: \(request.url?.absoluteString ?? "")")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // Overseerr uses API-style snake_case, our models are camelCase? 
            // NOTE: The API docs show camelCase for some fields but often snake_case for DB fields. 
            // Let's assume standard camelCase for most new Swift models and if API returns snake_case we use .convertFromSnakeCase.
            // Actually, usually Overseerr API returns camelCase. Let's check the users file I wrote earlier.
            // The User model I wrote assumes camelCase (`plexToken`).
            // The API doc screenshot `plexToken` is camelCase.
            // So we probably don't need .convertFromSnakeCase as a default, or we can check.
            // I'll stick to default for now and adjust if needed.
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw NetworkError.decodingFailed
        }
    }
    
    func request(_ endpoint: Endpoint) async throws -> Void {
        let request = try createRequest(from: endpoint)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NetworkError.requestFailed(statusCode: statusCode)
        }
    }
    
    private func createRequest(from endpoint: Endpoint) throws -> URLRequest {
        guard var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }
        
        if let queryItems = endpoint.queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add auth headers if available
        if let apiKey = apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        }
        
        // TODO: Handle Cookie auth if needed
        
        return request
    }
}
