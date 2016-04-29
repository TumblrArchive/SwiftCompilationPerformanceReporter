import Foundation

extension NSURL {
    /// Appends the current epoch time in milliseconds to the path
    var pathWithAppendedTimestamp: NSURL {
        return appendingPathComponent("\(Int(NSDate().timeIntervalSince1970*1000))")
    }
}
