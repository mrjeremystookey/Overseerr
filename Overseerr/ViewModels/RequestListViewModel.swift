import Foundation
import Combine
import SwiftUI

@MainActor
class RequestListViewModel: ObservableObject {
    @Published var state: ViewState<[MediaRequest]> = .idle
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
        state = .loading
        do {
            let fetched = try await requestRepository.getRequests(take: 50, skip: 0, filter: activeFilter.rawValue)
            if fetched.isEmpty {
                state = .empty
            } else {
                state = .success(fetched)
            }
        } catch {
            Logger.error("Failed to load requests: \(error)")
            state = .error("Failed to load requests.")
        }
    }
    
    func approveRequest(_ request: MediaRequest) async {
        await updateStatus(for: request, status: .approved)
    }
    
    func denyRequest(_ request: MediaRequest) async {
        await updateStatus(for: request, status: .declined)
    }
    
    private func updateStatus(for request: MediaRequest, status: RequestStatus) async {
        Logger.ui("User triggering \(status.label) for request \(request.id)")
        
        // Optimistic update mechanism could be added here by mutating current state
        // For safe implementation, we'll reload.
        
        do {
            _ = try await requestRepository.updateRequestStatus(requestId: request.id, status: status)
            Logger.success("Request \(request.id) updated to \(status.label)")
            
            // Reload to reflect changes and potentially change filter state
            await loadRequests()
            
        } catch {
            Logger.error("Failed to update status: \(error)")
            // If we are grounded in a success state, we might want to show a transient error?
            // With ViewState, transitioning to .error replaces the list. 
            // Ideally we'd have a transient error channel (like a toast), 
            // but for this strict pattern:
            state = .error("Action failed: \(error.localizedDescription)")
        }
    }
}
