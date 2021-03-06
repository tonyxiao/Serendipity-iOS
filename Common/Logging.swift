//
//  Logging.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import BugfenderSDK
import CrashlyticsFramework

public let Log = Logger()

public class Logger {
    enum LogLevel : Int, Printable {
        case Error = 0
        case Warn
        case Info
        case Debug
        case Verbose
        
        var description: String {
            switch self {
                case .Error: return "ERROR"
                case .Warn: return "WARN"
                case .Info: return "INFO"
                case .Debug: return "DEBUG"
                case .Verbose: return "VERBOSE"
            }
        }
    }
    
    private let nslogger : NSLogger = NSLogger()
    
    // MARK: Metadata API
    
    func setUserId(userId: String?) {
        Crashlytics.setUserIdentifier(userId)
    }
    
    func setUserEmail(email: String?) {
        Crashlytics.setUserEmail(email)
    }
    
    func setUserName(name: String?) {
        Crashlytics.setUserName(name)
    }
    
    // MARK: Logging API
    
    func verbose(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: LogLevel.Verbose, function: function, file: file, line: line)
    }
    
    func debug(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: LogLevel.Debug, function: function, file: file, line: line)
    }
    
    func info(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: LogLevel.Info, function: function, file: file, line: line)
    }
    
    func warn(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: LogLevel.Warn, function: function, file: file, line: line)
    }
    
    func error(message: String, _ error: NSError? = nil, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        let msg = error != nil ? "\(message) error: \(error)" : message
        log(msg, level: LogLevel.Error, function: function, file: file, line: line)
    }
    
    func log(message: String,
             level: LogLevel,
             function: String = __FUNCTION__,
             file: String = __FILE__,
             line: Int = __LINE__) {
        // NSLogger
        nslogger.logWithFilename(file, lineNumber: Int32(line), functionName: function, domain: nil, level: Int32(level.rawValue), message: message)

        // Bugfender
        let bfInfo = formatForBugFender(level, message: message)
        Bugfender.logWithFilename(file, lineNumber: Int32(line), functionName: function, tag: nil, level: bfInfo.0, message: bfInfo.1)

        // Crashlytics
        Crashlytics.logMessage(formatForCrashlytics(message, level, function, file, line))

        // Swift default
        println("[\(level)] \(message)")
    }
    
    func formatForBugFender(level: LogLevel, message: String) -> (BFLogLevel, String) {
        switch level {
        case .Verbose, .Debug:
            return (.Default, "[\(level)] \(message)")
        case .Info:
            return (.Default, message)
        case .Warn:
            return (.Warning, message)
        case .Error:
            return (.Error, message)
        }
    }
    
    func formatForCrashlytics(message: String, _ level: LogLevel, _ function: String, _ file: String, _ line: Int) -> String {
        let filename = file.lastPathComponent.stringByDeletingPathExtension
        return "[\(level)] \(filename):\(line) \(message)"
    }
}