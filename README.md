# SwiftCompilationPerformanceReporter

Inspired by [Brian](https://twitter.com/brianmichel/) and [Bryan](https://twitter.com/irace/)'s [prior](https://github.com/brianmichel/Swift-Analysis-Workflow) [work](http://irace.me/swift-profiling), we've decided to develop a Swift Package and script to generate automated reports for slow Swift compilation paths in specific targets!

SwiftCompilationPerformanceReporter (nicknamed SwiftCPR) can be configured to build a specific target, output raw debug times to a specific location, and clean those logs to rank the slowest parts to compile.

## Requirements

- [Xcode 8 Beta](https://developer.apple.com/download/)
- [8/18/2016 Swift Trunk Development Snapshot](https://swift.org/builds/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2016-08-18-a/swift-DEVELOPMENT-SNAPSHOT-2016-08-18-a-osx.pkg) (We'll periodically update this repo to work with the latest snapshots)

## Configuration

SwiftCompilationPerformanceReporter can be configured via the `config.json` file. Below is a description of the options available and a sample configuration:

```javascript
{
    // Note: either a project or workspace file can be specified, _but not both_
    "workspacePath": "/Users/jasdev/orangina/Orangina.xcworkspace",
    "projectPath": "/Users/jasdev/orangina/Orangina.xcodeproj",

    "scheme": "Orangina",
    "buildOutputDirectory": "/Users/jasdev/Desktop/CompilationLogs/",
    "reportOutputDirectory": "/Users/jasdev/Desktop/ProcessedLogs/",
    "limit": 10
}
```

`workspacePath`: The absolute path to the workspace file to use.

`projectPath`: The absolute path to the project file to use.

`scheme`: The scheme to use

`buildOutputDirectory`: The directory to store the raw build output files with Swift compilation times.

`reportOutputDirectory`: The directory to store the processed logs derived from the raw log output.

`limit`: The number of compilation paths to include in the final results (i.e. the slowest `limit` paths that compiler handled).

## Installation

- Simply clone this repository on the machine that will be generating these reports.
- Run `swift build` in the root directory
- Make sure all directories used in `config.json` are set properly and exist.
- If your desired scheme is built with a pre-3.x version of Swift, you'll want to `xcode-select` back to a stable version (i.e. `sudo xcode-select -s /Applications/Xcode.app`)
- To kick off the script, run `.build/debug/SwiftCompilationPerformanceReporter` in the root directory!
- If there are any errors, the script will output them.
- The processed logs will be outputted as timestamped files in `reportOutputDirectory`.

## Output

The processed logs will be outputted as a tab separated file with 3 columns after the first line (which holds the total build time). All time units are in seconds.

`[Build Time]\t[Path and Line]\t[Detailed Description]`

Sample output file:

```
Total build time: 1214.91016298532
17.0409	/Users/jasdev/orangina/Classes/PerformanceLoggingEvent.swift:278:37	final get {}
7.9331	/Users/jasdev/orangina/Components/ComposeUI/Classes/Election/LeaderboardTableView.swift:71:17	@objc final class func totalHeight(candidates: UInt, allowsLeaderboard: Bool) -> CGFloat
6.2961	/Users/jasdev/orangina/Classes/UniversalLink.swift:127:25	private final class func dictionaryOfAppArgumentsFromQueryString(string: String) -> [NSObject : AnyObject]?
4.2116	/Users/jasdev/orangina/Classes/ActivityViewController.swift:56:22	final get {}
```
