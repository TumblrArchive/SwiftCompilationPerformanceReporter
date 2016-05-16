import Foundation

/**
 *  A processor for the raw logs outputted from the Swift compiler.
 */
struct LogProcessor {
    
    /// Location of the raw log file
    let path: String
    
    /// The output directory for the processed logs
    let outputPath: NSURL
    
    /// The total time it took for the build
    let totalBuildTime: Double
    
    /// The number of entities to include in the final log (e.g. top 10 functions that take the longest to compile)
    let limit: UInt
    
    /**
     Processes the raw log file and writes out the results to `outputPath`
     */
    func process() {
        do {
            let fullText = try String(contentsOfFile: path)
            
            let entries = fullText.components(separatedBy: "\n").flatMap { LogEntry(line: $0) }
            let mergedEntries = mergeDuplicateEntries(entries: entries)
            let buildTimePrompt = "Total build time: \(totalBuildTime)"
            let outputText = ([buildTimePrompt] + mergedEntries.prefix(upTo: Int(limit)).map { String($0) }).joined(separator: "\n")
            
            try outputText.write(toFile: "\(outputPath.pathWithAppendedTimestamp.absoluteString).txt", atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch {
            fatalError("Log processing failed w/ error: \(error)")
        }
    }
    
    private func mergeDuplicateEntries(entries: [LogEntry]) -> [LogEntry] {
        var timeFrequencyMap = [LogEntry: Double]()

        entries.forEach {
            timeFrequencyMap[$0] = (timeFrequencyMap[$0] ?? 0) + $0.compilationTime
        }
        
        return timeFrequencyMap.enumerated().sorted { $0.element.1 > $1.element.1 }.map {
            $0.element.0.updateCompilation(time: $0.element.1)
        }
    }
}
