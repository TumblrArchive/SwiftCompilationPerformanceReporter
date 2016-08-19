import Foundation

extension URL {
    /// Appends the current epoch time in milliseconds to the path
    var pathWithAppendedTimestamp: URL {
        return appendingPathComponent("\(Int(Date().timeIntervalSince1970*1000))")
    }
}
