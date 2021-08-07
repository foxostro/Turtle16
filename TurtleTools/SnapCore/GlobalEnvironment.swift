//
//  GlobalEnvironment.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

public class GlobalEnvironment: NSObject {
    public var modules: [String : Block] = [:]
    
    public func hasModule(_ name: String) -> Bool {
        return modules[name] != nil
    }
}
