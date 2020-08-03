//
//  LabelMaker.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/2/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class LabelMaker: NSObject {
    public let prefix: String
    private var tempLabelCounter = 0
    
    public init(prefix: String = ".L") {
        self.prefix = prefix
    }
    
    public func next() -> String {
        let label = "\(prefix)\(tempLabelCounter)"
        tempLabelCounter += 1
        return label
    }
}
