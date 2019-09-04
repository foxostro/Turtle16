//
//  ControlWord.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Represents a control word in the TurtleTTL hardware.
public class ControlWord: NSObject {
    public let CO: Bool
    public let J: Bool
    public let YI: Bool
    public let XI: Bool
    public let YO: Bool
    public let XO: Bool
    public let MO: Bool
    public let MI: Bool
    public let EO: Bool
    public let FI: Bool
    public let AO: Bool
    public let AI: Bool
    public let BO: Bool
    public let BI: Bool
    public let DI: Bool
    public let HLT: Bool
    
    public required init(withCO CO: Bool,
                         withJ J: Bool,
                         withYI YI: Bool,
                         withXI XI: Bool,
                         withYO YO: Bool,
                         withXO XO: Bool,
                         withMO MO: Bool,
                         withMI MI: Bool,
                         withEO EO: Bool,
                         withFI FI: Bool,
                         withAO AO: Bool,
                         withAI AI: Bool,
                         withBO BO: Bool,
                         withBI BI: Bool,
                         withDI DI: Bool,
                         withHLT HLT: Bool) {
        self.CO  = CO
        self.J   = J
        self.YI  = YI
        self.XI  = XI
        self.YO  = YO
        self.XO  = XO
        self.MO  = MO
        self.MI  = MI
        self.EO  = EO
        self.FI  = FI
        self.AO  = AO
        self.AI  = AI
        self.BO  = BO
        self.BI  = BI
        self.DI  = DI
        self.HLT = HLT
    }
    
    public override convenience init() {
        self.init(withCO:  true,
                  withJ:   true,
                  withYI:  true,
                  withXI:  true,
                  withYO:  true,
                  withXO:  true,
                  withMO:  true,
                  withMI:  true,
                  withEO:  true,
                  withFI:  true,
                  withAO:  true,
                  withAI:  true,
                  withBO:  true,
                  withBI:  true,
                  withDI:  true,
                  withHLT: true)
    }
    
    public convenience init(withValue value: UInt) {
        self.init(withCO: (value & (1<<0))  != 0,
                  withJ:  (value & (1<<1))  != 0,
                  withYI: (value & (1<<2))  != 0,
                  withXI: (value & (1<<3))  != 0,
                  withYO: (value & (1<<4))  != 0,
                  withXO: (value & (1<<5))  != 0,
                  withMO: (value & (1<<6))  != 0,
                  withMI: (value & (1<<7))  != 0,
                  withEO: (value & (1<<8))  != 0,
                  withFI: (value & (1<<9))  != 0,
                  withAO: (value & (1<<10)) != 0,
                  withAI: (value & (1<<11)) != 0,
                  withBO: (value & (1<<12)) != 0,
                  withBI: (value & (1<<13)) != 0,
                  withDI: (value & (1<<14)) != 0,
                  withHLT:(value & (1<<15)) != 0)
    }
    
    public var unsignedIntegerValue: UInt {
        var result: UInt = 0
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
    
    public var stringValue: String {
        var result = String(self.unsignedIntegerValue, radix: 2)
        if result.count < 16 {
            result = String(repeatElement("0", count: 16 - result.count)) + result
        }
        return result
    }
    
    public override var description: String {
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
    
    public func withCO(_ CO: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withJ(_ J: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withYI(_ YI: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withXI(_ XI: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withYO(_ YO: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withXO(_ XO: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withMO(_ MO: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withMI(_ MI: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withEO(_ EO: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withFI(_ FI: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withAO(_ AO: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withAI(_ AI: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withBO(_ BO: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withBI(_ BI: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withDI(_ DI: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withHLT(_ HLT: Bool) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  MI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func outputAToBus() -> ControlWord {
        return ControlWord(withCO:  true,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  true,
                           withXO:  true,
                           withMO:  true,
                           withMI:  MI,
                           withEO:  true,
                           withFI:  FI,
                           withAO:  false,
                           withAI:  AI,
                           withBO:  true,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func outputBToBus() -> ControlWord {
        return ControlWord(withCO:  true,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  true,
                           withXO:  true,
                           withMO:  true,
                           withMI:  MI,
                           withEO:  true,
                           withFI:  FI,
                           withAO:  true,
                           withAI:  AI,
                           withBO:  false,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func outputCToBus() -> ControlWord {
        return ControlWord(withCO:  false,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  true,
                           withXO:  true,
                           withMO:  true,
                           withMI:  MI,
                           withEO:  true,
                           withFI:  FI,
                           withAO:  true,
                           withAI:  AI,
                           withBO:  true,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func outputXToBus() -> ControlWord {
        return ControlWord(withCO:  true,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  true,
                           withXO:  false,
                           withMO:  true,
                           withMI:  MI,
                           withEO:  true,
                           withFI:  FI,
                           withAO:  true,
                           withAI:  AI,
                           withBO:  true,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func outputYToBus() -> ControlWord {
        return ControlWord(withCO:  true,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  false,
                           withXO:  true,
                           withMO:  true,
                           withMI:  MI,
                           withEO:  true,
                           withFI:  FI,
                           withAO:  true,
                           withAI:  AI,
                           withBO:  true,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func outputEToBus() -> ControlWord {
        return ControlWord(withCO:  true,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  true,
                           withXO:  true,
                           withMO:  true,
                           withMI:  MI,
                           withEO:  false,
                           withFI:  FI,
                           withAO:  true,
                           withAI:  AI,
                           withBO:  true,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func outputMToBus() -> ControlWord {
        return ControlWord(withCO:  true,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  true,
                           withXO:  true,
                           withMO:  false,
                           withMI:  MI,
                           withEO:  true,
                           withFI:  FI,
                           withAO:  true,
                           withAI:  AI,
                           withBO:  true,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func inputAFromBus() -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  true,
                           withXI:  true,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  true,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  false,
                           withBO:  BO,
                           withBI:  true,
                           withDI:  true,
                           withHLT: HLT)
    }
    
    func inputBFromBus() -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  true,
                           withXI:  true,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  true,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  true,
                           withBO:  BO,
                           withBI:  false,
                           withDI:  true,
                           withHLT: HLT)
    }
    
    func inputDFromBus() -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  true,
                           withXI:  true,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  true,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  true,
                           withBO:  BO,
                           withBI:  true,
                           withDI:  false,
                           withHLT: HLT)
    }
    
    func inputXFromBus() -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  true,
                           withXI:  false,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  true,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  true,
                           withBO:  BO,
                           withBI:  true,
                           withDI:  true,
                           withHLT: HLT)
    }
    
    func inputYFromBus() -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  false,
                           withXI:  true,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  true,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  true,
                           withBO:  BO,
                           withBI:  true,
                           withDI:  true,
                           withHLT: HLT)
    }
    
    func inputMFromBus() -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  true,
                           withXI:  true,
                           withYO:  YO,
                           withXO:  XO,
                           withMO:  MO,
                           withMI:  false,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  true,
                           withBO:  BO,
                           withBI:  true,
                           withDI:  true,
                           withHLT: HLT)
    }
}
