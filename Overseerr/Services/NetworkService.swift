import Foundation

@preconcurrency protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func request(_ endpoint: Endpoint) async throws -> Void
}

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct Endpoint: Sendable {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]?
    let body: Data?
    let absoluteURL: URL?
    
    init(path: String, method: HTTPMethod = .get, queryItems: [URLQueryItem]? = nil, body: Encodable? = nil, absoluteURL: URL? = nil) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.absoluteURL = absoluteURL
        if let body = body {
            self.body = try? JSONEncoder().encode(body)
        } else {
            self.body = nil
        }
    }
}

enum NetworkError: Error, Sendable {
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
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try createRequest(from: endpoint)
        
        Logger.network("\(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.error("Network: Unknown Response")
                throw NetworkError.unknown
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                Logger.error("Network: Request Failed with Status \(httpResponse.statusCode)")
                throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            // decoder.keyDecodingStrategy = .convertFromSnakeCase // Kept commented as per previous decision
            return try decoder.decode(T.self, from: data)
            
        } catch {
            Logger.error("Network Decoding/Request Error: \(error)")
            throw error
        }
    }
    
    func request(_ endpoint: Endpoint) async throws -> Void {
        let request = try createRequest(from: endpoint)
        
        Logger.network("\(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
        
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                Logger.error("Network: Request Failed with Status \(statusCode)")
                throw NetworkError.requestFailed(statusCode: statusCode)
            }
            // Logger.success("Network Request Successful") // Optional, might be too noisy
        } catch {
            Logger.error("Network Request Error: \(error)")
            throw error
        }
    }
    
    private func createRequest(from endpoint: Endpoint) throws -> URLRequest {
        let requestURL: URL
        
        if let absoluteURL = endpoint.absoluteURL {
            let fullURL = absoluteURL.appendingPathComponent(endpoint.path)
            guard var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: true) else {
                throw NetworkError.invalidURL
            }
            if let queryItems = endpoint.queryItems {
                components.queryItems = queryItems
            }
            guard let url = components.url else { throw NetworkError.invalidURL }
            requestURL = url
        } else {
            guard var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true) else {
                throw NetworkError.invalidURL
            }
            if let queryItems = endpoint.queryItems {
                urlComponents.queryItems = queryItems
            }
            guard let url = urlComponents.url else {
                throw NetworkError.invalidURL
            }
            requestURL = url
        }
        
        var request = URLRequest(url: requestURL)
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

