# Chompy

Inspired by [Brian](https://twitter.com/brianmichel/) and [Bryan](https://twitter.com/irace/)'s [prior](https://github.com/brianmichel/Swift-Analysis-Workflow) [work](http://irace.me/swift-profiling), we've decided to develop a Swift Package and script to generate automated reports for slow Swift compilation paths in specific targets!

Chompy can be configured to build a specific target, output raw debug times to a specific location, and clean those logs to rank the slowest parts to compile.

## Requirements

- The latest [_development_ snapshot](https://swift.org/download/#latest-development-snapshots) of Swift 
- [Xcode 7.3 Beta 5](https://developer.apple.com/xcode/download/) or above

## Configuration

Chompy can be configured via the `config.json` file. Below is a description of the options available and a sample configuration:

```javascript
{
    "workspacePath": "/Users/jasdev/orangina/Orangina.xcworkspace",
    "scheme": "Orangina",
    "buildOutputDirectory": "/Users/jasdev/Desktop/CompilationLogs/",
    "reportOutputDirectory": "/Users/jasdev/Desktop/ProcessedLogs/",
    "limit": 10
}
```

`workspacePath`: The absolute path to the workspace file to use.

`scheme`: The scheme to use

`buildOutputDirectory`: The directory to store the raw build output files with Swift compilation times.

`reportOutputDirectory`: The directory to store the processed logs derived from the raw log output.

`limit`: The number of compilation paths to include in the final results (i.e. the slowest `limit` paths that compiler handled).

## Installation

- Simply clone this repository on the machine that will be generating these reports.
- Run `swift build` in the root directory
- Make sure all directories used in `config.json` are set properly and exist.
- To kick off the script, run `.build/debug/Chompy` in the root directory!
- If there are any errors, the script will output them.
- The processed logs will be outputted as timestamped files in `reportOutputDirectory`.

## Development

The `XcodeProject` directory contains an Xcode project that you can open to work on this package within Xcode itself. However, when running the script, use the command line (`swift build` + `.build/debug/Chompy`, so that the script can cleanly pick up the `config.json` file). This extra step will likely be removed, once the SPM and Xcode integration is complete.

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