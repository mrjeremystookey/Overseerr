import Foundation

struct Movie: Codable, Identifiable {
    let id: Int
    let imdbId: String?
    let adult: Bool
    let backdropPath: String?
    let posterPath: String?
    let budget: Int?
    let genres: [Genre]?
    let homepage: String?
    let originalLanguage: String
    let originalTitle: String
    let overview: String?
    let popularity: Double
    let productionCompanies: [ProductionCompany]?
    let releaseDate: String?
    let revenue: Int?
    let runtime: Int?
    let status: String
    let tagline: String?
    let title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
    let credits: Credits?
    let mediaInfo: Media?
    
    // Helper to get Year
    var releaseYear: String? {
        guard let date = releaseDate else { return nil }
        return String(date.prefix(4))
    }
}
