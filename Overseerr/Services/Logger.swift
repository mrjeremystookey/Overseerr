import Foundation

enum LogType {
    case info
    case warning
    case error
    case success
    case network
    case auth
    case ui
    
    var emoji: String {
        switch self {
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .success: return "✅"
        case .network: return "🌐"
        case .auth: return "🔐"
        case .ui: return "📺"
        }
    }
}

struct Logger {
    static func log(_ message: String, type: LogType = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("\(type.emoji) [\(type)] \(fileName):\(line) - \(message)")
    }
    
    static func info(_ message: String) {
        log(message, type: .info)
    }
    
    static func warning(_ message: String) {
        log(message, type: .warning)
    }
    
    static func error(_ message: String) {
        log(message, type: .error)
    }
    
    static func success(_ message: String) {
        log(message, type: .success)
    }
    
    static func network(_ message: String) {
        log(message, type: .network)
    }
    
    static func auth(_ message: String) {
        log(message, type: .auth)
    }
    
    static func ui(_ message: String) {
        log(message, type: .ui)
    }
}
