//
//  SnapCompilerMetrics.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public let kMainFunctionName = "main"
public let kTestMainFunctionName = "__testMain"
public let kStandardLibraryModuleName = "stdlib"

public enum SnapCompilerMetrics {
    // Static storage is allocated in a region starting at this address.
    // The allocator is a simple bump pointer.
    public static let kStaticStorageStartAddress: Int = 0x0110
}
