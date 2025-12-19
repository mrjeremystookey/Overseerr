import Foundation

struct Issue: Codable, Identifiable {
    let id: Int
    let issueType: IssueType
    let media: Media
    let createdBy: User
    let modifiedBy: User?
    let comments: [IssueComment]?
    let status: IssueStatus
    
    enum CodingKeys: String, CodingKey {
        case id, issueType, media, createdBy, modifiedBy, comments, status
    }
}

enum IssueType: Int, Codable {
    case video = 1
    case audio = 2
    case subtitles = 3
    case other = 4
    
    var description: String {
        switch self {
        case .video: return "Video"
        case .audio: return "Audio"
        case .subtitles: return "Subtitles"
        case .other: return "Other"
        }
    }
}

enum IssueStatus: Int, Codable {
    case open = 1
    case resolved = 2
    
    var description: String {
        switch self {
        case .open: return "Open"
        case .resolved: return "Resolved"
        }
    }
}

struct IssueComment: Codable, Identifiable {
    let id: Int
    let user: User
    let message: String
    let createdAt: String
}
