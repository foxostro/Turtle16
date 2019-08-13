//
//  ControlWord.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class ControlWord: NSObject {
    public var CO:Bool = true
    public var J:Bool = true
    public var YI:Bool = true
    public var XI:Bool = true
    public var YO:Bool = true
    public var XO:Bool = true
    public var MO:Bool = true
    public var MI:Bool = true
    public var EO:Bool = true
    public var FI:Bool = true
    public var AO:Bool = true
    public var AI:Bool = true
    public var BO:Bool = true
    public var BI:Bool = true
    public var DI:Bool = true
    public var HLT:Bool = true
    
    public var contents: UInt16 {
        get {
            var result: UInt16 = 0
            result +=  CO ? (1<<0) : 0
            result +=   J ? (1<<1) : 0
            result +=  YI ? (1<<2) : 0
            result +=  XI ? (1<<3) : 0
            result +=  YO ? (1<<4) : 0
            result +=  XO ? (1<<5) : 0
            result +=  MO ? (1<<6) : 0
            result +=  MI ? (1<<7) : 0
            result +=  EO ? (1<<8) : 0
            result +=  FI ? (1<<9) : 0
            result +=  AO ? (1<<10) : 0
            result +=  AI ? (1<<11) : 0
            result +=  BO ? (1<<12) : 0
            result +=  BI ? (1<<13) : 0
            result +=  DI ? (1<<14) : 0
            result += HLT ? (1<<15) : 0
            return result
        }
        set(contents) {
            CO  = (contents & (1<<0))  != 0
            J   = (contents & (1<<1))  != 0
            YI  = (contents & (1<<2))  != 0
            XI  = (contents & (1<<3))  != 0
            YO  = (contents & (1<<4))  != 0
            XO  = (contents & (1<<5))  != 0
            MO  = (contents & (1<<6))  != 0
            MI  = (contents & (1<<7))  != 0
            EO  = (contents & (1<<8))  != 0
            FI  = (contents & (1<<9))  != 0
            AO  = (contents & (1<<10)) != 0
            AI  = (contents & (1<<11)) != 0
            BO  = (contents & (1<<12)) != 0
            BI  = (contents & (1<<13)) != 0
            DI  = (contents & (1<<14)) != 0
            HLT = (contents & (1<<15)) != 0
        }
    }
    
    public var stringValue: String {
        var result = String(contents, radix: 2)
        if result.count < 16 {
            result = String(repeatElement("0", count: 16 - result.count)) + result
        }
        return result
    }
    
    public func clone() -> ControlWord {
        let result = ControlWord()
        result.contents = contents
        return result
    }
    
    override public var description: String {
        var signals = [String]()
        if (false == CO) {
            signals.append("CO")
        }
        if (false == J) {
            signals.append("J")
        }
        if (false == YI) {
            signals.append("YI")
        }
        if (false == XI) {
            signals.append("XI")
        }
        if (false == YO) {
            signals.append("YO")
        }
        if (false == XO) {
            signals.append("XO")
        }
        if (false == MO) {
            signals.append("MO")
        }
        if (false == MI) {
            signals.append("MI")
        }
        if (false == EO) {
            signals.append("EO")
        }
        if (false == FI) {
            signals.append("FI")
        }
        if (false == AO) {
            signals.append("AO")
        }
        if (false == AI) {
            signals.append("AI")
        }
        if (false == BO) {
            signals.append("BO")
        }
        if (false == BI) {
            signals.append("BI")
        }
        if (false == DI) {
            signals.append("DI")
        }
        if (false == HLT) {
            signals.append("HLT")
        }
        return String(format: "{%@}", signals.joined(separator: ", "));
    }
    
    func outputAToBus() {
        AO = false
        BO = true
        CO = true
        XO = true
        YO = true
        EO = true
        MO = true
    }
    
    func outputBToBus() {
        AO = true
        BO = false
        CO = true
        XO = true
        YO = true
        EO = true
        MO = true
    }
    
    func outputCToBus() {
        AO = true
        BO = true
        CO = false
        XO = true
        YO = true
        EO = true
        MO = true
    }
    
    func outputXToBus() {
        AO = true
        BO = true
        CO = true
        XO = false
        YO = true
        EO = true
        MO = true
    }
    
    func outputYToBus() {
        AO = true
        BO = true
        CO = true
        XO = true
        YO = false
        EO = true
        MO = true
    }
    
    func outputEToBus() {
        AO = true
        BO = true
        CO = true
        XO = true
        YO = true
        EO = false
        MO = true
    }
    
    func outputMToBus() {
        AO = true
        BO = true
        CO = true
        XO = true
        YO = true
        EO = true
        MO = false
    }
    
    func inputAFromBus() {
        AI = false
        BI = true
        DI = true
        XI = true
        YI = true
        MI = true
    }
    
    func inputBFromBus() {
        AI = true
        BI = false
        DI = true
        XI = true
        YI = true
        MI = true
    }
    
    func inputDFromBus() {
        AI = true
        BI = true
        DI = false
        XI = true
        YI = true
        MI = true
    }
    
    func inputXFromBus() {
        AI = true
        BI = true
        DI = true
        XI = false
        YI = true
        MI = true
    }
    
    func inputYFromBus() {
        AI = true
        BI = true
        DI = true
        XI = true
        YI = false
        MI = true
    }
    
    func inputMFromBus() {
        AI = true
        BI = true
        DI = true
        XI = true
        YI = true
        MI = false
    }
}
