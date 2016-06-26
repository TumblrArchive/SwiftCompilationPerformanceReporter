//
//  PathConfiguration.swift
//  SwiftCompilationPerformanceReporter
//
//  Created by Jasdev Singh on 6/25/16.
//
//

import Foundation

/// Wrapper on the different path configurations that SwiftCPR supports
enum PathConfiguration {
    // Build from a workspace file and its associated path on disk
    case workspace(URL)
    
    // Build from a project file and its associated path on disk
    case project(URL)
    
    // Allow easy access to the associated path 
    var path: URL {
        switch self {
        case let .project(url):
            return url
        case let .workspace(url):
            return url
        }
    }
}
