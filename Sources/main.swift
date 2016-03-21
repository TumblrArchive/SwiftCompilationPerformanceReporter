import Foundation

private struct Constants {
    static let configFile = "config.json"
    static let launchPath = "/bin/bash"
    static let commandFlag = "-c"
}

let JSONData = NSData.init(contentsOfFile: "\(NSFileManager.defaultManager().currentDirectoryPath)/config.json")
guard let data = JSONData else {
    fatalError("Failed to read config.json!")
}

guard
    let JSONDict = (try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]) ?? nil,
    let buildCommand = BuildCommand(dictionary: JSONDict)
else {
    fatalError("Invalid config.json. See README to make sure it's valid.")
}

let (outputPath, buildCommandString) = buildCommand.buildInfo()
print(">>> Building \(buildCommand.scheme)...")

let buildStartTime = NSDate()

let task = NSTask.launchedTaskWithLaunchPath(Constants.launchPath, arguments: [Constants.commandFlag, buildCommandString])
task.waitUntilExit()

guard task.terminationStatus == 0 else {
    fatalError("Uh oh! The build command failed :( Try running the following command to debug and re-run this script:\n\(buildCommandString)")
}

print(">>> \(buildCommand.scheme) built successfully!")

let elapsedTime = NSDate().timeIntervalSinceDate(buildStartTime)

let processor = LogProcessor(path: outputPath,  
                             outputPath: buildCommand.reportOutputDirectory,
                             totalBuildTime: elapsedTime,
                             limit: buildCommand.limit)
processor.process()
