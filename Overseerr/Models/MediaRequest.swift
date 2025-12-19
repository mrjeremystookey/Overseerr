import Foundation

struct MediaRequest: Codable, Identifiable {
    let id: Int
    let status: RequestStatus
    let createdAt: String
    let updatedAt: String?
    let type: MediaType
    let is4k: Bool
    let serverId: Int?
    let profileId: Int?
    let rootFolder: String?
    let languageProfileId: Int?
    let tags: [Int]?
    let seasons: [RequestSeason]?
    let media: Media?
    let requestedBy: User?
    let modifiedBy: User?
    let movie: Movie?
    let tv: TVShow?
    
    enum CodingKeys: String, CodingKey {
        case id, status, createdAt, updatedAt, type, is4k, serverId, profileId, rootFolder, languageProfileId, tags, seasons, media, requestedBy, modifiedBy, movie, tv
    }
}

enum RequestStatus: Int, Codable {
    case pending = 1
    case approved = 2
    case declined = 3
    
    var label: String {
        switch self {
        case .pending: return "Pending"
        case .approved: return "Approved"
        case .declined: return "Declined"
        }
    }
}

enum MediaType: String, Codable {
    case movie = "movie"
    case tv = "tv"
}

struct RequestSeason: Codable {
    let id: Int
    let seasonNumber: Int
    let status: Int // 1=Pending, 2=Approved, etc.
}
