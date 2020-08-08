//
//  ProgramDebugInfo.swift
//  TurtleCore
//
//  Created by Andrew Fox on 8/7/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class ProgramDebugInfo: NSObject {
    public var lineMapper: SourceLineRangeMapper!
    public var mapProgramCounterToSource: [Int:SourceAnchor?]!
}
