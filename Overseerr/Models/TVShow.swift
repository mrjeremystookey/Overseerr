import Foundation

struct TVShow: Codable, Identifiable {
    let id: Int
    let backdropPath: String?
    let posterPath: String?
    let createdBy: [Creator]?
    let episodeRunTime: [Int]?
    let firstAirDate: String?
    let genres: [Genre]?
    let homepage: String?
    let inProduction: Bool
    let languages: [String]?
    let lastAirDate: String?
    let name: String
    let networks: [ProductionCompany]? // Reusing ProductionCompany for simplicity as they are similar
    let numberOfEpisodes: Int
    let numberOfSeasons: Int
    let originCountry: [String]?
    let originalLanguage: String
    let originalName: String
    let overview: String?
    let popularity: Double
    let productionCompanies: [ProductionCompany]?
    let seasons: [Season]?
    let status: String
    let type: String
    let voteAverage: Double
    let voteCount: Int
    let credits: Credits?
    let mediaInfo: Media?
    
    var releaseYear: String? {
        guard let date = firstAirDate else { return nil }
        return String(date.prefix(4))
    }
}

struct Season: Codable, Identifiable {
    let id: Int
    let airDate: String?
    let episodeCount: Int
    let name: String
    let overview: String?
    let posterPath: String?
    let seasonNumber: Int
}

struct Creator: Codable, Identifiable {
    let id: Int
    let name: String
    let profilePath: String?
}
