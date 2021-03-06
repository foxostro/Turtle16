//
//  SerialInput.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 3/1/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class SerialInput: NSObject {
    var bytes_: [UInt8] = []
    
    public var bytes: [UInt8] {
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            let arr = bytes_
            return arr
        }
        set (value) {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            bytes_ = value
        }
    }
    
    public var count: Int {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        return bytes_.count
    }
    
    public func provide(bytes: [UInt8]) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        bytes_ += bytes
    }
    
    public func clear() {
        self.bytes = []
    }
    
    public func removeFirst() -> UInt8? {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if let byte = bytes_.first {
            bytes_.removeFirst()
            return byte
        } else {
            return nil
        }
    }
}
