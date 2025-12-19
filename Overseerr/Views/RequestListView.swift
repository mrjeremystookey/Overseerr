import SwiftUI

struct RequestListView: View {
    @StateObject var viewModel: RequestListViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter Picker
                Picker("Filter", selection: $viewModel.activeFilter) {
                    ForEach(RequestListViewModel.RequestFilter.allCases) { filter in
                        Text(filter.label).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: viewModel.activeFilter) { _, _ in
                    Task { await viewModel.loadRequests() }
                }
                
                // Content based on ViewState
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()
                        .padding()
                    
                case .empty:
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No requests found")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                case .error(let message):
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Error")
                            .font(.headline)
                        Text(message)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            Task { await viewModel.loadRequests() }
                        }
                    }
                    .padding()
                    
                case .success(let requests):
                    List {
                        ForEach(requests) { request in
                            RequestRow(request: request)
                                .swipeActions(edge: .leading) {
                                    if request.status == .pending {
                                        Button {
                                            Task { await viewModel.approveRequest(request) }
                                        } label: {
                                            Label("Approve", systemImage: "checkmark")
                                        }
                                        .tint(.green)
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    if request.status != .declined {
                                        Button(role: .destructive) {
                                            Task { await viewModel.denyRequest(request) }
                                        } label: {
                                            Label("Deny", systemImage: "xmark")
                                        }
                                    }
                                }
                        }
                    }
                    .refreshable {
                        await viewModel.loadRequests()
                    }
                }
            }
            .navigationTitle("Requests")
            .task {
                await viewModel.loadRequests()
            }
        }
    }
}

// Simple Row Component
struct RequestRow: View {
    let request: MediaRequest
    
    // Helper to get image URL (needs a real path builder later)
    var posterURL: URL? {
        return nil
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
             // Poster Placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 90)
                .cornerRadius(8)
                .overlay(
                    Image(systemName: request.type == .movie ? "film" : "tv")
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(request.movie?.title ?? request.tv?.name ?? "Request #\(request.id)")
                    .font(.headline)
                    .lineLimit(1)
                
                Text(request.type.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let user = request.requestedBy {
                    Text("By: \(user.email ?? "Unknown")")  // Handle optional email
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Text(request.status.label)
                    .font(.caption)
                    .padding(4)
                    .background(statusColor(request.status).opacity(0.2))
                    .foregroundColor(statusColor(request.status))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
    
    func statusColor(_ status: RequestStatus) -> Color {
        switch status {
        case .approved: return .green
        case .declined: return .red
        case .pending: return .orange
        }
    }
}
