import Foundation
import Combine
import SwiftUI

@MainActor
class RequestListViewModel: ObservableObject {
    @Published var requests: [MediaRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var activeFilter: RequestFilter = .pending
    
    private let requestRepository: RequestRepositoryProtocol
    
    enum RequestFilter: String, CaseIterable, Identifiable {
        case pending = "pending"
        case approved = "approved"
        case processing = "processing"
        case available = "available"
        
        var id: String { rawValue }
        var label: String { rawValue.capitalized }
    }
    
    init(requestRepository: RequestRepositoryProtocol) {
        self.requestRepository = requestRepository
    }
    
    func loadRequests() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await requestRepository.getRequests(take: 50, skip: 0, filter: activeFilter.rawValue)
            self.requests = fetched
        } catch {
            Logger.error("Failed to load requests: \(error)")
            self.errorMessage = "Failed to load requests."
        }
        isLoading = false
    }
    
    func approveRequest(_ request: MediaRequest) async {
        await updateStatus(for: request, status: .approved)
    }
    
    func denyRequest(_ request: MediaRequest) async {
        await updateStatus(for: request, status: .declined)
    }
    
    private func updateStatus(for request: MediaRequest, status: RequestStatus) async {
        Logger.ui("User triggering \(status.label) for request \(request.id)")
        // Optimistic update or wait for reload? Let's wait for reload to ensure consistency for now, 
        // or just remove from list if filter is pending.
        
        do {
            _ = try await requestRepository.updateRequestStatus(requestId: request.id, status: status)
            Logger.success("Request \(request.id) updated to \(status.label)")
            
            // Remove from local list if it no longer matches filter (e.g. was pending, now approved)
            if activeFilter == .pending && status != .pending {
                withAnimation {
                    requests.removeAll { $0.id == request.id }
                }
            } else {
                // Reload data to reflect changes
                await loadRequests() 
            }
        } catch {
            Logger.error("Failed to update status: \(error)")
            self.errorMessage = "Action failed: \(error.localizedDescription)"
        }
    }
    
    /* 
     // For future pagination support
    func loadMore() async {
        ...
    }
    */
}
