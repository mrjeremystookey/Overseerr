import Foundation

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case error(String)
    case empty
}

extension ViewState: Equatable where T: Equatable {
    static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.empty, .empty): return true
        case (.success(let lhsValue), .success(let rhsValue)): return lhsValue == rhsValue
        case (.error(let lhsMsg), .error(let rhsMsg)): return lhsMsg == rhsMsg
        default: return false
        }
    }
}
