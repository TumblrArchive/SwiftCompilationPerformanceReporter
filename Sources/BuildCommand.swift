import Foundation

/**
 *  `BuildCommand` is a thin wrapper on the command needed to determine Swift compilation times for specific functions.
 */
struct BuildCommand {
    private static let buildCommand =
        "xcodebuild -workspace %@ -scheme %@ clean build OTHER_SWIFT_FLAGS=\"-Xfrontend -debug-time-function-bodies\" | "
        + "grep [1-9].[0-9]ms | "
        + "sort -nr > %@"
    
    /// Absolute path to the workspace file to use
    let workspacePath: NSURL
    
    /// Name of the scheme to build
    let scheme: String
    
    /// Directory to output the raw Swift build logs. Make sure to set trailing slash.
    let buildOutputPath: NSURL
    
    /// Directory to output the processed logs. Make sure to set trailing slash.
    let reportOutputDirectory: NSURL
    
    /// The number of entries to output in the processed logs. Defaults to 20.
    let limit: UInt
    
    private enum JSONKeys: String {
        case workspacePath
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
            let workspacePathString = dictionary[JSONKeys.workspacePath.rawValue] as? String,
            let workspacePath = NSURL(string: workspacePathString),
            let scheme = dictionary[JSONKeys.scheme.rawValue] as? String,
            let buildOutputPathString = dictionary[JSONKeys.buildOutputDirectory.rawValue] as? String,
            let buildOutputPath = NSURL(string: buildOutputPathString),
            let reportOutputDirectoryString = dictionary[JSONKeys.reportOutputDirectory.rawValue] as? String,
            let reportOutputDirectory = NSURL(string: reportOutputDirectoryString)
        else {
            return nil
        }
        
        self.workspacePath = workspacePath
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
        
        return (outputLogPath: outputLogPath,
                String(format: BuildCommand.buildCommand,
                      workspacePath.absoluteString,
                      scheme,
                      outputLogPath))
    }
}
