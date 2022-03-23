//
//  PrintLogger.swift
//  TurtleCore
//
//  Created by Andrew Fox on 3/22/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

public class PrintLogger: NSObject, Logger {
    public func append(_ format: String, _ args: CVarArg...) {
        let message = String(format:format, arguments:args)
        print(message)
    }
}
