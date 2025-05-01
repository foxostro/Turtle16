//
//  ProgramDebugInfo.swift
//  TurtleCore
//
//  Created by Andrew Fox on 8/7/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

open class ProgramDebugInfo {
    public var lineMapper: SourceLineRangeMapper!
    private var mapProgramCounterToSource: [SourceAnchor?] = []

    public func bind(pc: Int, sourceAnchor: SourceAnchor?) {
        assert(pc >= 0 && pc < 65536)
        if pc < mapProgramCounterToSource.count {
            mapProgramCounterToSource[pc] = sourceAnchor
        }
        else {
            let last = mapProgramCounterToSource.last as? SourceAnchor
            for _ in mapProgramCounterToSource.count..<pc {
                mapProgramCounterToSource.append(last)
            }
            mapProgramCounterToSource.append(sourceAnchor)
        }
    }

    public func lookupSourceAnchor(pc: Int) -> SourceAnchor? {
        assert(pc >= 0 && pc < 65536)
        guard pc < mapProgramCounterToSource.count else {
            return nil
        }
        let sourceAnchor = mapProgramCounterToSource[pc]
        return sourceAnchor
    }
}
