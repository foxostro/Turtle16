//
//  MangledFunctionNameMap.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/7/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class MangledFunctionNameMap: NSObject {
    private var mapFunctionUIDToMangledName: [Int : String] = [:]
    private var mapFunctionMangledNameToUID: [String : Int] = [:]
    private var nextFunctionUID = 0
    
    public func nextUID(mangledName: String) -> Int {
        let uid = nextFunctionUID
        mapFunctionUIDToMangledName[uid] = mangledName
        mapFunctionMangledNameToUID[mangledName] = uid
        nextFunctionUID += 1
        return uid
    }
    
    public func lookup(uid: Int) -> String {
        return mapFunctionUIDToMangledName[uid]!
    }
    
    public func lookup(mangledName: String) -> Int? {
        return mapFunctionMangledNameToUID[mangledName]
    }
}
