//
//  LogEntry.swift
//  Chompy
//
//  Created by Jasdev Singh on 3/17/16.
//  Copyright © 2016 Jasdev Singh. All rights reserved.
//

/**
 *  Wrapper on a line of raw Swift debug time output
 */
struct LogEntry {
    private struct Constants {
        static let invalidLocation = "<invalid loc>"
    }
    
    /// The compilation time in milliseconds
    let compilationTime: Double
    
    /// The location of the function
    let location: String
    
    /// More detail about the function provided from the compiler
    let detailedDescription: String
}

extension LogEntry {
    /**
     Builds a `LogEntry` from a line of compiler output
     
     - parameter line: The line of compiler output
     
     - returns: An instance of `LogEntry` or `nil`, if invalid.
     */
    init?(line: String) {
        let components = line.componentsSeparatedByString("\t").map { $0.stringByTrimmingCharactersInSet(.whitespaceCharacterSet()) }
        
        guard
            components.count == 3 &&
            components[1].rangeOfString(Constants.invalidLocation) == nil,
            let compilationTime = Double(
                components[0].stringByTrimmingCharactersInSet(.letterCharacterSet())
            )
        else {
            return nil
        }
        
        self.compilationTime = compilationTime
        location = components[1]
        detailedDescription = components[2]
    }
    
    /**
     Updates the compilation time of a `LogEntry`. Used in merging duplicate logs.
     
     - parameter time: The new time to use.
     
     - returns: A mirrored `LogEntry` with a new `compilationTime`
     */
    func updateCompilationTime(time: Double) -> LogEntry {
        return LogEntry(compilationTime: time, location: location, detailedDescription: detailedDescription)
    }
}

// MARK: - CustomStringConvertible

extension LogEntry: CustomStringConvertible {
    var description: String {
        return ["\(compilationTime/1000)", location, detailedDescription].componentsJoinedByString("\t")
    }
}

// MARK: - Hashable

extension LogEntry: Hashable {
    var hashValue: Int {
        return (location + detailedDescription).hashValue
    }
}

// MARK: - Equatable

func ==(lhs: LogEntry, rhs: LogEntry) -> Bool {
    return lhs.location == rhs.location && lhs.detailedDescription == rhs.detailedDescription
}
