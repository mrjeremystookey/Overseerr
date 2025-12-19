import Foundation

protocol RequestRepositoryProtocol {
    func getRequests(take: Int, skip: Int, filter: String) async throws -> [MediaRequest]
    func updateRequestStatus(requestId: Int, status: RequestStatus) async throws -> MediaRequest
}

class RequestRepository: RequestRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getRequests(take: Int = 20, skip: Int = 0, filter: String = "pending") async throws -> [MediaRequest] {
        Logger.info("Fetching requests with filter: \(filter)")
        let endpoint = Endpoint(path: "/request", queryItems: [
            URLQueryItem(name: "take", value: String(take)),
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "filter", value: filter),
            URLQueryItem(name: "sort", value: "added")
        ])
        
        let response: RequestListResponse = try await networkService.request(endpoint)
        return response.results
    }
    
    func updateRequestStatus(requestId: Int, status: RequestStatus) async throws -> MediaRequest {
        Logger.info("Updating request \(requestId) to status: \(status.label)")
        
        // Overseerr API uses distinct endpoints or logic for status updates.
        // Usually POST /request/{requestId}/{status} where status is 'approve' or 'decline'
        
        let statusString: String
        switch status {
        case .approved: statusString = "approve"
        case .declined: statusString = "decline"
        default: 
            Logger.warning("Attempted to update request to invalid status: \(status)")
            throw NetworkError.unknown // invalid op
        }
        
        let endpoint = Endpoint(path: "/request/\(requestId)/\(statusString)", method: .post)
        return try await networkService.request(endpoint)
    }
}

struct RequestListResponse: Decodable {
    let results: [MediaRequest]
}
