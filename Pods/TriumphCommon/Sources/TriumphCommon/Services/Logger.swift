// Copyright © TriumphSDK. All rights reserved.

import Foundation

public enum LogEvent: String {
    case error = "🔴"
    case warning = "⚠️"
    case success = "✅"
    case `default` = "=="
}

public protocol Logger {}

public extension Logger {
    private var time: String {
        let date : Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return " [\(dateFormatter.string(from: date))]"
    }
    
    private func pathLine(file: String, function: String, line: Int) -> String {
        let filename = (file as NSString).lastPathComponent
        return "[\(filename) • \(function) • \(line)]"
    }
    
    /// Print plain message or use event cases
    /// - parameter message: The printed message
    /// - parameter event: LogEvent enum
    /// - parameter file: File name
    /// - parameter function: Function name
    /// - parameter line: Line number
    /// ```
    /// log("Hello World", .warning)
    /// // [2022-01-05 01:14:27] [MainCoordinator.swift • start() • 75] ⚠️ Hello World
    /// ```
    /// LogEvent raw values:
    /// ```
    /// enum LogEvent: String {
    ///     case error = "🔴"
    ///     case warning = "⚠️"
    ///     case success = "✅"
    ///     case `default` = "=="
    /// }
    /// ```
    func log(
        _ message: Any = "",
        _ event: LogEvent = .default,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let pathLine = pathLine(file: file, function: function, line: line)
        print(time, pathLine, event.rawValue, message)
    }
}

final class LoggerService: Logger {}
