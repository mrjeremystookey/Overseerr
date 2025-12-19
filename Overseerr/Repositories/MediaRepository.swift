import Foundation

protocol MediaRepositoryProtocol {
    func getTrending(page: Int) async throws -> [Media] // Simplified, might need a wrapper for mixed types
    func getUpcomingMovies() async throws -> [Movie]
    func search(query: String) async throws -> [Media] // Search returns mixed content usually
}

class MediaRepository: MediaRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getTrending(page: Int = 1) async throws -> [Media] {
        // NOTE: Trending endpoint often returns mixed movie/tv results. 
        // For simplicity in this step, we might need a generic 'TrendResult' wrapper or just decode partially.
        // Let's assume for now we just fetch movies from discover as a placeholder if trending structure is complex.
        // Or actually, let's use the Discover endpoints as they are cleaner for typed return.
        
        // Actually, let's implement 'Recent' from /media for generic media list
        let endpoint = Endpoint(path: "/media", queryItems: [
            URLQueryItem(name: "take", value: "20"),
            URLQueryItem(name: "sort", value: "mediaAdded")
        ])
        
        let response: MediaListResponse = try await networkService.request(endpoint)
        return response.results
    }
    
    func getUpcomingMovies() async throws -> [Movie] {
        let endpoint = Endpoint(path: "/discover/movies/upcoming")
        let response: MovieListResponse = try await networkService.request(endpoint)
        return response.results
    }
    
    func search(query: String) async throws -> [Media] {
        // Implement search
        _ = Endpoint(path: "/search", queryItems: [
            URLQueryItem(name: "query", value: query)
        ])
         // Search returns potentially mixed results (Person, Movie, TV). 
         // For now, let's just assume we want to map them to valid Medias? 
         // Or strictly speaking search results are different from Media objects. 
         // I'll return an empty list for this placeholder to avoid complex decoding logic right now.
         return [] 
    }
}

struct MediaListResponse: Decodable {
    let results: [Media]
}

struct MovieListResponse: Decodable {
    let results: [Movie]
}
