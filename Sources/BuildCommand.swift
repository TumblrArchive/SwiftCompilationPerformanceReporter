import Foundation

/**
 *  `BuildCommand` is a thin wrapper on the command needed to determine Swift compilation times for specific functions.
 */
struct BuildCommand {
    fileprivate var buildCommand: String {
        let pathFlag: String
        switch pathConfiguration {
        case .workspace(_):
            pathFlag = "-workspace"
        case .project(_):
            pathFlag = "-project"
        }
        
        return "xcodebuild "
            + "\(pathFlag) %@ "
            + "-scheme %@ "
            + "clean build OTHER_SWIFT_FLAGS=\"-Xfrontend -debug-time-function-bodies\" | "
            + "grep [1-9].[0-9]ms | "
            + "sort -nr > %@"
    }
    
    let pathConfiguration: PathConfiguration
    
    /// Name of the scheme to build
    let scheme: String
    
    /// Directory to output the raw Swift build logs. Make sure to set trailing slash.
    let buildOutputPath: URL
    
    /// Directory to output the processed logs. Make sure to set trailing slash.
    let reportOutputDirectory: URL
    
    /// The number of entries to output in the processed logs. Defaults to 20.
    let limit: UInt
    
    fileprivate enum JSONKeys: String {
        case workspacePath
        case projectPath
        case scheme
        case buildOutputDirectory
        case reportOutputDirectory
        case limit
    }
}

extension BuildCommand {
    /**
     Initializes a `BuildCommand` from a JSON dictionary.
     
     - parameter dictionary: The JSON dictionary to use.
     
     - returns: An instance of `BuildCommand` or `nil`, if parsing failed.
     */
    init?(dictionary: [String: AnyObject]) {
        guard
            let scheme = dictionary[JSONKeys.scheme.rawValue] as? String,
            let buildOutputPathString = dictionary[JSONKeys.buildOutputDirectory.rawValue] as? String,
            let buildOutputPath = URL(string: buildOutputPathString),
            let reportOutputDirectoryString = dictionary[JSONKeys.reportOutputDirectory.rawValue] as? String,
            let reportOutputDirectory = URL(string: reportOutputDirectoryString)
        else {
            return nil
        }
        
        let workspacePathString = dictionary[JSONKeys.workspacePath.rawValue] as? String
        let projectPathString = dictionary[JSONKeys.projectPath.rawValue] as? String
        
        // We need to ensure that _either_ a workspace path or a project path is set, but not both simultaneously.
        switch (workspacePathString, projectPathString) {
        case (_?, _?), (nil, nil):
            return nil
        case let (workspaceString?, nil):
            guard let workspacePath = URL(string: workspaceString) else { return nil }
            pathConfiguration = .workspace(workspacePath)
        case let (nil, projectString?):
            guard let projectPath = URL(string: projectString) else { return nil }
            pathConfiguration = .project(projectPath)
        }
        
        self.scheme = scheme
        self.buildOutputPath = buildOutputPath
        self.reportOutputDirectory = reportOutputDirectory
        limit = dictionary[JSONKeys.limit.rawValue] as? UInt ?? 20
    }
}

extension BuildCommand {
    /**
     Computes the build command and raw output file path
     
     - returns: A tuple containing the path to the raw output file to be generated and the command string
     */
    func buildInfo() -> (outputLogPath: String, buildCommandString: String)  {
        let outputLogPath = "\(buildOutputPath.pathWithAppendedTimestamp.absoluteString).txt"
        
        // `NSString` casting needed to get around https://bugs.swift.org/browse/SR-957?jql=text%20~%20%22string%20cvararg%22
        return (outputLogPath: outputLogPath,
                String(format: buildCommand,
                      (pathConfiguration.path.absoluteString) as NSString,
                      scheme as NSString,
                      outputLogPath as NSString))
    }
}
