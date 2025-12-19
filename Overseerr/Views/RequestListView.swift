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
                
                if viewModel.isLoading && viewModel.requests.isEmpty {
                    ProgressView()
                        .padding()
                } else if viewModel.requests.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No requests found")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.requests) { request in
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
                                    if request.status != .declined { // Can decline any non-declined?
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
            .alert(item: Binding<String?>(
                get: { viewModel.errorMessage.map { $0 } }, // Convert String to Identifiable String wrapper if needed, or stick to simple Text
                set: { _ in viewModel.errorMessage = nil }
            )) { msg in
                Alert(title: Text("Error"), message: Text(msg))
            }
        }
    }
}

// Simple Row Component
struct RequestRow: View {
    let request: MediaRequest
    
    // Helper to get image URL (needs a real path builder later)
    var posterURL: URL? {
        // Assuming TMDB poster path is available in Media or if not we might need to fetch it.
        // The Request object has `media` which might have `posterPath` if we mapped it correctly.
        // Standard TMDB image base: https://image.tmdb.org/t/p/w200
        // Currently our models might differ slightly, let's check MediaRequest.media.
        // Actually our Media model has external IDs, we might need to lookup poster based on Movie/TV data?
        // Ah, MediaRequest extends Media? No, it HAS a media. 
        // Let's use a placeholder or basic text for v1 if image url logic is complex.
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
                // We assume there's a title somewhere. 
                // Wait, MediaRequest has `media` but Media model is mostly IDs and Status. 
                // The API usually expands `media` to include content info OR we need to fetch content.
                // However, `RequestRepository` response usually includes expanded info if we used the right endpoint.
                // Let's look at the `MediaRequest` struct again. It has `media`.
                // If `Media` struct in Swift only has IDs, we can't show title!
                // We need to update `MediaRequest` or `Media` to include Title/Poster or generic metadata.
                // The `Overseerr API` for `/request` returns objects that HAVE `media` inside them, 
                // but usually the media info (title) is nested or we need to look at `MediaRequest` structure closer.
                // Re-checking Docs/Assumption: MediaRequest often wraps the `Movie` or `TVShow`. 
                // Let's assume for this step we display ID or Type, but we REALLY need to fetch/show titles.
                // Just for this step, I'll show ID and Type.
                
                Text("Request #\(request.id)")
                    .font(.headline)
                
                Text(request.type.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let user = request.requestedBy {
                    Text("By: \(user.email)") // Username might be nil
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

// Extension to make String Identifiable for Alert
extension String: @retroactive Identifiable {
    public var id: String { self }
}
