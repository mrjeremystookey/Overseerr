import Foundation

struct Media: Codable, Identifiable {
    let id: Int
    let tmdbId: Int?
    let tvdbId: Int?
    let imdbId: String?
    let status: MediaStatus?
    let status4k: MediaStatus?
    let createdAt: String
    let updatedAt: String
    let lastSeasonChange: String?
    let mediaAdded: String?
    let serviceId: Int?
    let serviceId4k: Int?
    let externalServiceId: Int?
    let externalServiceId4k: Int?
    let externalServiceSlug: String?
    let externalServiceSlug4k: String?
    let ratingKey: String?
    let ratingKey4k: String?
    
    // Helper to determine active status
    var effectiveStatus: MediaStatus {
        return status ?? .unknown
    }
}

enum MediaStatus: Int, Codable {
    case unknown = 1
    case pending = 2
    case processing = 3
    case partiallyAvailable = 4
    case available = 5
    
    var description: String {
        switch self {
        case .unknown: return "Unknown"
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .partiallyAvailable: return "Partially Available"
        case .available: return "Available"
        }
    }
}
