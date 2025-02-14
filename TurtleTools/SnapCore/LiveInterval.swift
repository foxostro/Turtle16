//
//  LiveInterval.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

/// Represents a register's live interval for register allocation purposes
public struct LiveInterval: Equatable {
    public let range: Range<Int>
    public let virtualRegisterName: String
    public let physicalRegisterName: String?
    public let spillSlot: Int?

    public init(
        range: Range<Int>,
        virtualRegisterName: String,
        physicalRegisterName: String?,
        spillSlot: Int? = nil
    ) {
        self.range = range
        self.virtualRegisterName = virtualRegisterName
        self.physicalRegisterName = physicalRegisterName
        self.spillSlot = spillSlot
    }
}
