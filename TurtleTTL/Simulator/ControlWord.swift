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
    public enum ControlSignal { case active, inactive }
    
    public let CO: ControlSignal
    public let J: ControlSignal
    public let YI: ControlSignal
    public let XI: ControlSignal
    public let YO: ControlSignal
    public let XO: ControlSignal
    public let PO: ControlSignal
    public let PI: ControlSignal
    public let EO: ControlSignal
    public let FI: ControlSignal
    public let AO: ControlSignal
    public let AI: ControlSignal
    public let BO: ControlSignal
    public let BI: ControlSignal
    public let DI: ControlSignal
    public let HLT: ControlSignal
    
    public required init(withCO CO: ControlSignal,
                         withJ J: ControlSignal,
                         withYI YI: ControlSignal,
                         withXI XI: ControlSignal,
                         withYO YO: ControlSignal,
                         withXO XO: ControlSignal,
                         withPO PO: ControlSignal,
                         withPI PI: ControlSignal,
                         withEO EO: ControlSignal,
                         withFI FI: ControlSignal,
                         withAO AO: ControlSignal,
                         withAI AI: ControlSignal,
                         withBO BO: ControlSignal,
                         withBI BI: ControlSignal,
                         withDI DI: ControlSignal,
                         withHLT HLT: ControlSignal) {
        self.CO  = CO
        self.J   = J
        self.YI  = YI
        self.XI  = XI
        self.YO  = YO
        self.XO  = XO
        self.PO  = PO
        self.PI  = PI
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
        self.init(withCO:  .inactive,
                  withJ:   .inactive,
                  withYI:  .inactive,
                  withXI:  .inactive,
                  withYO:  .inactive,
                  withXO:  .inactive,
                  withPO:  .inactive,
                  withPI:  .inactive,
                  withEO:  .inactive,
                  withFI:  .inactive,
                  withAO:  .inactive,
                  withAI:  .inactive,
                  withBO:  .inactive,
                  withBI:  .inactive,
                  withDI:  .inactive,
                  withHLT: .inactive)
    }
    
    public convenience init(withValue value: UInt) {
        self.init(withCO: ((value & (1<<0))  != 0) ? .inactive : .active,
                  withJ:  ((value & (1<<1))  != 0) ? .inactive : .active,
                  withYI: ((value & (1<<2))  != 0) ? .inactive : .active,
                  withXI: ((value & (1<<3))  != 0) ? .inactive : .active,
                  withYO: ((value & (1<<4))  != 0) ? .inactive : .active,
                  withXO: ((value & (1<<5))  != 0) ? .inactive : .active,
                  withPO: ((value & (1<<6))  != 0) ? .inactive : .active,
                  withPI: ((value & (1<<7))  != 0) ? .inactive : .active,
                  withEO: ((value & (1<<8))  != 0) ? .inactive : .active,
                  withFI: ((value & (1<<9))  != 0) ? .inactive : .active,
                  withAO: ((value & (1<<10)) != 0) ? .inactive : .active,
                  withAI: ((value & (1<<11)) != 0) ? .inactive : .active,
                  withBO: ((value & (1<<12)) != 0) ? .inactive : .active,
                  withBI: ((value & (1<<13)) != 0) ? .inactive : .active,
                  withDI: ((value & (1<<14)) != 0) ? .inactive : .active,
                  withHLT:((value & (1<<15)) != 0) ? .inactive : .active)
    }
    
    public var unsignedIntegerValue: UInt {
        var result: UInt = 0
        result += ( CO == .inactive) ? (1<<0) : 0
        result += (  J == .inactive) ? (1<<1) : 0
        result += ( YI == .inactive) ? (1<<2) : 0
        result += ( XI == .inactive) ? (1<<3) : 0
        result += ( YO == .inactive) ? (1<<4) : 0
        result += ( XO == .inactive) ? (1<<5) : 0
        result += ( PO == .inactive) ? (1<<6) : 0
        result += ( PI == .inactive) ? (1<<7) : 0
        result += ( EO == .inactive) ? (1<<8) : 0
        result += ( FI == .inactive) ? (1<<9) : 0
        result += ( AO == .inactive) ? (1<<10) : 0
        result += ( AI == .inactive) ? (1<<11) : 0
        result += ( BO == .inactive) ? (1<<12) : 0
        result += ( BI == .inactive) ? (1<<13) : 0
        result += ( DI == .inactive) ? (1<<14) : 0
        result += (HLT == .inactive) ? (1<<15) : 0
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
        if (.active == CO) {
            signals.append("CO")
        }
        if (.active == J) {
            signals.append("J")
        }
        if (.active == YI) {
            signals.append("YI")
        }
        if (.active == XI) {
            signals.append("XI")
        }
        if (.active == YO) {
            signals.append("YO")
        }
        if (.active == XO) {
            signals.append("XO")
        }
        if (.active == PO) {
            signals.append("PO")
        }
        if (.active == PI) {
            signals.append("MI")
        }
        if (.active == EO) {
            signals.append("EO")
        }
        if (.active == FI) {
            signals.append("FI")
        }
        if (.active == AO) {
            signals.append("AO")
        }
        if (.active == AI) {
            signals.append("AI")
        }
        if (.active == BO) {
            signals.append("BO")
        }
        if (.active == BI) {
            signals.append("BI")
        }
        if (.active == DI) {
            signals.append("DI")
        }
        if (.active == HLT) {
            signals.append("HLT")
        }
        return String(format: "{%@}", signals.joined(separator: ", "));
    }
    
    public func withCO(_ CO: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withJ(_ J: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withYI(_ YI: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withXI(_ XI: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withYO(_ YO: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withXO(_ XO: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withPO(_ PO: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withPI(_ PI: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withEO(_ EO: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withFI(_ FI: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withAO(_ AO: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withAI(_ AI: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withBO(_ BO: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withBI(_ BI: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withDI(_ DI: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  AI,
                           withBO:  BO,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    public func withHLT(_ HLT: ControlSignal) -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  PI,
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
        return ControlWord(withCO:  .inactive,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  .inactive,
                           withXO:  .inactive,
                           withPO:  .inactive,
                           withPI:  PI,
                           withEO:  .inactive,
                           withFI:  FI,
                           withAO:  .active,
                           withAI:  AI,
                           withBO:  .inactive,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func outputBToBus() -> ControlWord {
        return ControlWord(withCO:  .inactive,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  .inactive,
                           withXO:  .inactive,
                           withPO:  .inactive,
                           withPI:  PI,
                           withEO:  .inactive,
                           withFI:  FI,
                           withAO:  .inactive,
                           withAI:  AI,
                           withBO:  .active,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func outputCToBus() -> ControlWord {
        return ControlWord(withCO:  .active,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  .inactive,
                           withXO:  .inactive,
                           withPO:  .inactive,
                           withPI:  PI,
                           withEO:  .inactive,
                           withFI:  FI,
                           withAO:  .inactive,
                           withAI:  AI,
                           withBO:  .inactive,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func outputXToBus() -> ControlWord {
        return ControlWord(withCO:  .inactive,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  .inactive,
                           withXO:  .active,
                           withPO:  .inactive,
                           withPI:  PI,
                           withEO:  .inactive,
                           withFI:  FI,
                           withAO:  .inactive,
                           withAI:  AI,
                           withBO:  .inactive,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func outputYToBus() -> ControlWord {
        return ControlWord(withCO:  .inactive,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  .active,
                           withXO:  .inactive,
                           withPO:  .inactive,
                           withPI:  PI,
                           withEO:  .inactive,
                           withFI:  FI,
                           withAO:  .inactive,
                           withAI:  AI,
                           withBO:  .inactive,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func outputEToBus() -> ControlWord {
        return ControlWord(withCO:  .inactive,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  .inactive,
                           withXO:  .inactive,
                           withPO:  .inactive,
                           withPI:  PI,
                           withEO:  .active,
                           withFI:  FI,
                           withAO:  .inactive,
                           withAI:  AI,
                           withBO:  .inactive,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func outputMToBus() -> ControlWord {
        return ControlWord(withCO:  .inactive,
                           withJ:   J,
                           withYI:  YI,
                           withXI:  XI,
                           withYO:  .inactive,
                           withXO:  .inactive,
                           withPO:  .active,
                           withPI:  PI,
                           withEO:  .inactive,
                           withFI:  FI,
                           withAO:  .inactive,
                           withAI:  AI,
                           withBO:  .inactive,
                           withBI:  BI,
                           withDI:  DI,
                           withHLT: HLT)
    }
    
    func inputAFromBus() -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  .inactive,
                           withXI:  .inactive,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  .inactive,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  .active,
                           withBO:  BO,
                           withBI:  .inactive,
                           withDI:  .inactive,
                           withHLT: HLT)
    }
    
    func inputBFromBus() -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  .inactive,
                           withXI:  .inactive,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  .inactive,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  .inactive,
                           withBO:  BO,
                           withBI:  .active,
                           withDI:  .inactive,
                           withHLT: HLT)
    }
    
    func inputDFromBus() -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  .inactive,
                           withXI:  .inactive,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  .inactive,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  .inactive,
                           withBO:  BO,
                           withBI:  .inactive,
                           withDI:  .active,
                           withHLT: HLT)
    }
    
    func inputXFromBus() -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  .inactive,
                           withXI:  .active,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  .inactive,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  .inactive,
                           withBO:  BO,
                           withBI:  .inactive,
                           withDI:  .inactive,
                           withHLT: HLT)
    }
    
    func inputYFromBus() -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  .active,
                           withXI:  .inactive,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  .inactive,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  .inactive,
                           withBO:  BO,
                           withBI:  .inactive,
                           withDI:  .inactive,
                           withHLT: HLT)
    }
    
    func inputMFromBus() -> ControlWord {
        return ControlWord(withCO:  CO,
                           withJ:   J,
                           withYI:  .inactive,
                           withXI:  .inactive,
                           withYO:  YO,
                           withXO:  XO,
                           withPO:  PO,
                           withPI:  .active,
                           withEO:  EO,
                           withFI:  FI,
                           withAO:  AO,
                           withAI:  .inactive,
                           withBO:  BO,
                           withBI:  .inactive,
                           withDI:  .inactive,
                           withHLT: HLT)
    }
}
