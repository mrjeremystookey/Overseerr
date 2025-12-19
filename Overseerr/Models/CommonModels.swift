import Foundation

struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}

struct ProductionCompany: Codable, Identifiable {
    let id: Int
    let name: String
    let logoPath: String?
    let originCountry: String?
}

struct CastMember: Codable, Identifiable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    let order: Int
}

struct CrewMember: Codable, Identifiable {
    let id: Int
    let name: String
    let job: String
    let department: String
    let profilePath: String?
}

struct Credits: Codable {
    let cast: [CastMember]
    let crew: [CrewMember]
}

struct Video: Codable, Identifiable {
    let id: String
    let key: String // YouTube ID usually
    let name: String
    let site: String
    let type: String
}
