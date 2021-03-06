//
//  SnapCompilerMetrics.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public final class SnapCompilerMetrics: NSObject {
    // Temporary storage is allocated in a region starting at this address.
    // These temporaries are slots for scratch memory which are treated as,
    // allocated as, pseudo-registers.
    public static let kTemporaryStorageStartAddress = 0x0010
    public static let kTemporaryStorageLength = 0x0100
    
    // Static storage is allocated in a region starting at this address.
    // The allocator is a simple bump pointer.
    public static let kStaticStorageStartAddress = kTemporaryStorageStartAddress + kTemporaryStorageLength
    
    // Programs written in Snap use a push down stack, and store the stack
    // pointer in data RAM at addresses 0x0000 and 0x0001.
    // This is initialized on launch to 0x0000.
    public static let kStackPointerAddressHi: UInt16 = 0x0000
    public static let kStackPointerAddressLo: UInt16 = 0x0001
    public static let kStackPointerInitialValue: Int = 0x0000
    
    // Programs written in Snap store the frame pointer in data RAM at
    // addresses 0x0002 and 0x0003. This is initialized on launch to 0x0000.
    public static let kFramePointerAddressHi: UInt16 = 0x0002
    public static let kFramePointerAddressLo: UInt16 = 0x0003
    public static let kFramePointerInitialValue: Int = 0x0000    
}
