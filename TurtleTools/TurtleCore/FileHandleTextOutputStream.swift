//
//  FileHandleTextOutputStream.swift
//  TurtleCore
//
//  Created by Andrew Fox on 8/18/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

public class FileHandleTextOutputStream: TextOutputStream {
    let fileHandle: FileHandle

    public required init(_ fileHandle: FileHandle) {
        self.fileHandle = fileHandle
    }

    public func write(_ string: String) {
        if let data = string.data(using: .utf8) {
            fileHandle.write(data)
        }
    }
}
