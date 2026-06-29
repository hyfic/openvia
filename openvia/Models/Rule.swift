import Foundation

struct Rule: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var pattern: String
    var browserId: String // Bundle identifier of the target browser
    var scheme: URLSchemeMatch = .any
    var patternType: PatternType = .domain
    
    enum URLSchemeMatch: String, Codable, Hashable, CaseIterable {
        case any = "Any"
        case http = "HTTP Only"
        case https = "HTTPS Only"
    }

    enum PatternType: String, Codable, Hashable, CaseIterable {
        case domain = "Domain"
        case wildcard = "Wildcard (URL)"
        case regex = "Regex"
    }
    
    // Checks if a given URL matches the rule
    func matches(url: URL) -> Bool {
        // 1. Check scheme
        if scheme == .http && url.scheme?.lowercased() != "http" { return false }
        if scheme == .https && url.scheme?.lowercased() != "https" { return false }
        
        let urlString = url.absoluteString
        let host = url.host ?? ""
        
        // 2. Check pattern based on type
        switch patternType {
        case .domain:
            if pattern == "*" { return true }
            let lowerHost = host.lowercased()
            let lowerPattern = pattern.lowercased()
            if lowerPattern.starts(with: "*.") {
                let suffix = lowerPattern.dropFirst(2)
                return lowerHost == String(suffix) || lowerHost.hasSuffix(".\(suffix)")
            }
            return lowerHost == lowerPattern
            
        case .wildcard:
            let escapedPattern = NSRegularExpression.escapedPattern(for: pattern)
                .replacingOccurrences(of: "\\*", with: ".*")
            let regexStr = "^\(escapedPattern)$"
            if let regex = try? NSRegularExpression(pattern: regexStr, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: urlString.utf16.count)
                return regex.firstMatch(in: urlString, options: [], range: range) != nil
            }
            return false
            
        case .regex:
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: urlString.utf16.count)
                return regex.firstMatch(in: urlString, options: [], range: range) != nil
            }
            return false
        }
    }
}
