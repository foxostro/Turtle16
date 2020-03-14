//
//  ComputerFactory.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 3/14/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class ComputerFactory: NSObject {
    let kComputerTypeString = "ComputerType"
    let kDefaultString = "Default"
    let kComputerRev1String = "Rev1"
    let kComputerRev2String = "Rev2"
    
    public enum ComputerType {
        case Rev1, Rev2
    }
    
    let defaultComputerType: ComputerType = .Rev1
    
    fileprivate func determineDesiredComputerTypeString() -> String {
        return UserDefaults.standard.string(forKey: kComputerTypeString) ?? kDefaultString
    }
    
    fileprivate func convertToComputerType(string: String) -> ComputerType {
        if string == kComputerRev1String {
            return .Rev1
        } else if string == kComputerRev2String {
            return .Rev2
        } else if string == kDefaultString {
            return defaultComputerType
        } else {
            return defaultComputerType
        }
    }
    
    public func determineDesiredComputerType() -> ComputerType {
        return convertToComputerType(string: determineDesiredComputerTypeString())
    }
    
    public func makeComputer() -> Computer {
        let type = determineDesiredComputerType()
        switch type {
        case .Rev1:
            return ComputerRev1()
        case .Rev2:
            return ComputerRev2()
        }
    }
}
