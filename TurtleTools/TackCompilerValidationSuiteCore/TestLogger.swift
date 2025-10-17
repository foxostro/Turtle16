//
//  TestLogger.swift
//  TackCompilerValidationSuite
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import Foundation
import Logging

/// Custom log handler that writes to stderr instead of stdout
struct StderrLogHandler: LogHandler {
    var metadata = Logger.Metadata()
    var logLevel = Logger.Level.info

    init() {}

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source _: String,
        file _: String,
        function _: String,
        line _: UInt
    ) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let levelStr = level.rawValue.uppercased()
        var output = "\n[\(timestamp)] [\(levelStr)] \(message)"

        if let metadata, !metadata.isEmpty {
            output += " " + metadata.map { "\($0)=\($1)" }.joined(separator: " ")
        }

        // Write to stderr
        fputs(output + "\n", stderr)
        fflush(stderr)
    }
}

/// Global logger instance
enum TestLogger {
    nonisolated(unsafe) static var logger =
        Logger(label: "com.foxostro.TackCompilerValidationSuite") { _ in
            StderrLogHandler()
        }
}
