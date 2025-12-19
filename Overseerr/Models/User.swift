import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let username: String?
    let plexToken: String?
    let plexUsername: String?
    let userType: Int
    let permissions: Int
    let avatar: String?
    let createdAt: String
    let updatedAt: String
    let requestCount: Int?
    // let settings: UserSettings? // To be defined later based on usage
    
    var isOwner: Bool {
        return id == 1
    }
    
    var isAdmin: Bool {
        // Assuming permission bitmask logic, simplified for now
        return (permissions & 2) != 0 // Example bit-check, needs verification with constants
    }
}
