//
//  ControlWord.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

// Represents a control word in the TurtleTTL hardware.
public class ControlWord: NSObject {
    // Signals have these names so they match the circuit schematics.
    public let AI: ControlSignal
    public let AO: ControlSignal
    public let BI: ControlSignal
    public let BO: ControlSignal
    public let CO: ControlSignal
    public let DI: ControlSignal
    public let EO: ControlSignal
    public let FI: ControlSignal
    public let UI: ControlSignal
    public let UO: ControlSignal
    public let VI: ControlSignal
    public let VO: ControlSignal
    public let UVInc: ControlSignal
    public let PI: ControlSignal
    public let PO: ControlSignal
    public let XI: ControlSignal
    public let XO: ControlSignal
    public let YI: ControlSignal
    public let YO: ControlSignal
    public let XYInc: ControlSignal
    public let MI: ControlSignal
    public let MO: ControlSignal
    public let LinkIn: ControlSignal
    public let LinkLoOut: ControlSignal
    public let LinkHiOut: ControlSignal
    public let J: ControlSignal
    public let CarryIn: ControlSignal
    public let HLT: ControlSignal
    
    public required init(withAI AI: ControlSignal,
                         withAO AO: ControlSignal,
                         withBI BI: ControlSignal,
                         withBO BO: ControlSignal,
                         withCO CO: ControlSignal,
                         withDI DI: ControlSignal,
                         withEO EO: ControlSignal,
                         withFI FI: ControlSignal,
                         withUI UI: ControlSignal,
                         withUO UO: ControlSignal,
                         withVI VI: ControlSignal,
                         withVO VO: ControlSignal,
                         withUVInc UVInc: ControlSignal,
                         withPI PI: ControlSignal,
                         withPO PO: ControlSignal,
                         withXI XI: ControlSignal,
                         withXO XO: ControlSignal,
                         withYI YI: ControlSignal,
                         withYO YO: ControlSignal,
                         withXYInc XYInc: ControlSignal,
                         withMI MI: ControlSignal,
                         withMO MO: ControlSignal,
                         withLinkIn LinkIn: ControlSignal,
                         withLinkLoOut LinkLoOut: ControlSignal,
                         withLinkHiOut LinkHiOut: ControlSignal,
                         withJ J: ControlSignal,
                         withCarryIn CarryIn: ControlSignal,
                         withHLT HLT: ControlSignal) {
        self.AI = AI
        self.AO = AO
        self.BI = BI
        self.BO = BO
        self.CO = CO
        self.DI = DI
        self.EO = EO
        self.FI = FI
        self.UI = UI
        self.UO = UO
        self.VI = VI
        self.VO = VO
        self.UVInc = UVInc
        self.PI = PI
        self.PO = PO
        self.XI = XI
        self.XO = XO
        self.YI = YI
        self.YO = YO
        self.XYInc = XYInc
        self.MI = MI
        self.MO = MO
        self.LinkIn = LinkIn
        self.LinkLoOut = LinkLoOut
        self.LinkHiOut = LinkHiOut
        self.J = J
        self.CarryIn = CarryIn
        self.HLT = HLT
    }
    
    public override convenience init() {
        self.init(withAI: .inactive,
                  withAO: .inactive,
                  withBI: .inactive,
                  withBO: .inactive,
                  withCO: .inactive,
                  withDI: .inactive,
                  withEO: .inactive,
                  withFI: .inactive,
                  withUI: .inactive,
                  withUO: .inactive,
                  withVI: .inactive,
                  withVO: .inactive,
                  withUVInc: .inactive,
                  withPI: .inactive,
                  withPO: .inactive,
                  withXI: .inactive,
                  withXO: .inactive,
                  withYI: .inactive,
                  withYO: .inactive,
                  withXYInc: .inactive,
                  withMI: .inactive,
                  withMO: .inactive,
                  withLinkIn: .inactive,
                  withLinkLoOut: .inactive,
                  withLinkHiOut: .inactive,
                  withJ: .inactive,
                  withCarryIn: .inactive,
                  withHLT: .inactive)
    }
    
    public convenience init(withValue value: UInt) {
        self.init(withAI:        ((value & (1<<0))  != 0) ? .inactive : .active,
                  withAO:        ((value & (1<<1))  != 0) ? .inactive : .active,
                  withBI:        ((value & (1<<2))  != 0) ? .inactive : .active,
                  withBO:        ((value & (1<<3))  != 0) ? .inactive : .active,
                  withCO:        ((value & (1<<4))  != 0) ? .inactive : .active,
                  withDI:        ((value & (1<<5))  != 0) ? .inactive : .active,
                  withEO:        ((value & (1<<6))  != 0) ? .inactive : .active,
                  withFI:        ((value & (1<<7))  != 0) ? .inactive : .active,
                  withUI:        ((value & (1<<8))  != 0) ? .inactive : .active,
                  withUO:        ((value & (1<<9))  != 0) ? .inactive : .active,
                  withVI:        ((value & (1<<10)) != 0) ? .inactive : .active,
                  withVO:        ((value & (1<<11)) != 0) ? .inactive : .active,
                  withUVInc:     ((value & (1<<12)) != 0) ? .active : .inactive, // active-high, actually
                  withPI:        ((value & (1<<13)) != 0) ? .inactive : .active,
                  withPO:        ((value & (1<<14)) != 0) ? .inactive : .active,
                  withXI:        ((value & (1<<15)) != 0) ? .inactive : .active,
                  withXO:        ((value & (1<<16)) != 0) ? .inactive : .active,
                  withYI:        ((value & (1<<17)) != 0) ? .inactive : .active,
                  withYO:        ((value & (1<<18)) != 0) ? .inactive : .active,
                  withXYInc:     ((value & (1<<19)) != 0) ? .active : .inactive, // active-high, actually
                  withMI:        ((value & (1<<20)) != 0) ? .inactive : .active,
                  withMO:        ((value & (1<<21)) != 0) ? .inactive : .active,
                  withLinkIn:    ((value & (1<<22)) != 0) ? .inactive : .active,
                  withLinkLoOut: ((value & (1<<23)) != 0) ? .inactive : .active,
                  withLinkHiOut: ((value & (1<<24)) != 0) ? .inactive : .active,
                  withJ:         ((value & (1<<25)) != 0) ? .inactive : .active,
                  withCarryIn:   ((value & (1<<26)) != 0) ? .inactive : .active,
                  withHLT:       ((value & (1<<31)) != 0) ? .inactive : .active)
    }
    
    public var unsignedIntegerValue: UInt {
        var result: UInt = 0
        result += (       AI == .inactive) ? (1<<0) : 0
        result += (       AO == .inactive) ? (1<<1) : 0
        result += (       BI == .inactive) ? (1<<2) : 0
        result += (       BO == .inactive) ? (1<<3) : 0
        result += (       CO == .inactive) ? (1<<4) : 0
        result += (       DI == .inactive) ? (1<<5) : 0
        result += (       EO == .inactive) ? (1<<6) : 0
        result += (       FI == .inactive) ? (1<<7) : 0
        result += (       UI == .inactive) ? (1<<8) : 0
        result += (       UO == .inactive) ? (1<<9) : 0
        result += (       VI == .inactive) ? (1<<10) : 0
        result += (       VO == .inactive) ? (1<<11) : 0
        result += (    UVInc == .active) ? (1<<12) : 0 // active-high, actually
        result += (       PI == .inactive) ? (1<<13) : 0
        result += (       PO == .inactive) ? (1<<14) : 0
        result += (       XI == .inactive) ? (1<<15) : 0
        result += (       XO == .inactive) ? (1<<16) : 0
        result += (       YI == .inactive) ? (1<<17) : 0
        result += (       YO == .inactive) ? (1<<18) : 0
        result += (    XYInc == .active) ? (1<<19) : 0 // active-high, actually
        result += (       MI == .inactive) ? (1<<20) : 0
        result += (       MO == .inactive) ? (1<<21) : 0
        result += (   LinkIn == .inactive) ? (1<<22) : 0
        result += (LinkLoOut == .inactive) ? (1<<23) : 0
        result += (LinkHiOut == .inactive) ? (1<<24) : 0
        result += (        J == .inactive) ? (1<<25) : 0
        result += (  CarryIn == .inactive) ? (1<<26) : 0
        result += (1<<27) // unused signal, always High (inactive)
        result += (1<<28) // unused signal, always High (inactive)
        result += (1<<29) // unused signal, always High (inactive)
        result += (1<<30) // unused signal, always High (inactive)
        result += (      HLT == .inactive) ? (1<<31) : 0
        return result
    }
    
    public var stringValue: String {
        var result = String(self.unsignedIntegerValue, radix: 2)
        if result.count < 32 {
            result = String(repeatElement("0", count: 32 - result.count)) + result
        }
        return result
    }
    
    public override var description: String {
        var signals = [String]()
        if (.active == AI) {
            signals.append("AI")
        }
        if (.active == AO) {
            signals.append("AO")
        }
        if (.active == BI) {
            signals.append("BI")
        }
        if (.active == BO) {
            signals.append("BO")
        }
        if (.active == CO) {
            signals.append("CO")
        }
        if (.active == DI) {
            signals.append("DI")
        }
        if (.active == EO) {
            signals.append("EO")
        }
        if (.active == FI) {
            signals.append("FI")
        }
        if (.active == UI) {
            signals.append("UI")
        }
        if (.active == UO) {
            signals.append("UO")
        }
        if (.active == VI) {
            signals.append("VI")
        }
        if (.active == VO) {
            signals.append("VO")
        }
        if (.active == UVInc) {
            signals.append("UVInc")
        }
        if (.active == PI) {
            signals.append("PI")
        }
        if (.active == PO) {
            signals.append("PO")
        }
        if (.active == XI) {
            signals.append("XI")
        }
        if (.active == XO) {
            signals.append("XO")
        }
        if (.active == YI) {
            signals.append("YI")
        }
        if (.active == YO) {
            signals.append("YO")
        }
        if (.active == XYInc) {
            signals.append("XYInc")
        }
        if (.active == MI) {
            signals.append("MI")
        }
        if (.active == MO) {
            signals.append("MO")
        }
        if (.active == LinkIn) {
            signals.append("LinkIn")
        }
        if (.active == LinkLoOut) {
            signals.append("LinkLoOut")
        }
        if (.active == LinkHiOut) {
            signals.append("LinkHiOut")
        }
        if (.active == J) {
            signals.append("J")
        }
        if (.active == CarryIn) {
            signals.append("CarryIn")
        }
        if (.active == HLT) {
            signals.append("HLT")
        }
        return String(format: "{%@}", signals.joined(separator: ", "));
    }
    
    public func withAI(_ AI: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withAO(_ AO: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withBI(_ BI: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withBO(_ BO: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withCO(_ CO: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withDI(_ DI: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withEO(_ EO: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withFI(_ FI: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withUI(_ UI: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withUO(_ UO: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withVI(_ VI: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withVO(_ VO: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withUVInc(_ UVInc: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withPI(_ PI: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withPO(_ PO: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withXI(_ XI: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withXO(_ XO: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withYI(_ YI: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withYO(_ YO: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withXYInc(_ XYInc: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withMI(_ MI: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withMO(_ MO: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withLinkIn(_ LinkIn: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withLinkLoOut(_ LinkLoOut: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withLinkHiOut(_ LinkHiOut: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withJ(_ J: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withCarryIn(_ CarryIn: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public func withHLT(_ HLT: ControlSignal) -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: AO,
                           withBI: BI,
                           withBO: BO,
                           withCO: CO,
                           withDI: DI,
                           withEO: EO,
                           withFI: FI,
                           withUI: UI,
                           withUO: UO,
                           withVI: VI,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: PO,
                           withXI: XI,
                           withXO: XO,
                           withYI: YI,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func outputAToBus() -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: .active,
                           withBI: BI,
                           withBO: .inactive,
                           withCO: .inactive,
                           withDI: DI,
                           withEO: .inactive,
                           withFI: FI,
                           withUI: UI,
                           withUO: .inactive,
                           withVI: VI,
                           withVO: .inactive,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: .inactive,
                           withXI: XI,
                           withXO: .inactive,
                           withYI: YI,
                           withYO: .inactive,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: .inactive,
                           withLinkIn: LinkIn,
                           withLinkLoOut: .inactive,
                           withLinkHiOut: .inactive,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func outputBToBus() -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: .inactive,
                           withBI: BI,
                           withBO: .active,
                           withCO: .inactive,
                           withDI: DI,
                           withEO: .inactive,
                           withFI: FI,
                           withUI: UI,
                           withUO: .inactive,
                           withVI: VI,
                           withVO: .inactive,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: .inactive,
                           withXI: XI,
                           withXO: .inactive,
                           withYI: YI,
                           withYO: .inactive,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: .inactive,
                           withLinkIn: LinkIn,
                           withLinkLoOut: .inactive,
                           withLinkHiOut: .inactive,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func outputCToBus() -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: .inactive,
                           withBI: BI,
                           withBO: .inactive,
                           withCO: .active,
                           withDI: DI,
                           withEO: .inactive,
                           withFI: FI,
                           withUI: UI,
                           withUO: .inactive,
                           withVI: VI,
                           withVO: .inactive,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: .inactive,
                           withXI: XI,
                           withXO: .inactive,
                           withYI: YI,
                           withYO: .inactive,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: .inactive,
                           withLinkIn: LinkIn,
                           withLinkLoOut: .inactive,
                           withLinkHiOut: .inactive,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func outputEToBus() -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: .inactive,
                           withBI: BI,
                           withBO: .inactive,
                           withCO: .inactive,
                           withDI: DI,
                           withEO: .active,
                           withFI: FI,
                           withUI: UI,
                           withUO: .inactive,
                           withVI: VI,
                           withVO: .inactive,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: .inactive,
                           withXI: XI,
                           withXO: .inactive,
                           withYI: YI,
                           withYO: .inactive,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: .inactive,
                           withLinkIn: LinkIn,
                           withLinkLoOut: .inactive,
                           withLinkHiOut: .inactive,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func outputUToBus() -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: .inactive,
                           withBI: BI,
                           withBO: .inactive,
                           withCO: .inactive,
                           withDI: DI,
                           withEO: .inactive,
                           withFI: FI,
                           withUI: UI,
                           withUO: .active,
                           withVI: VI,
                           withVO: .inactive,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: .inactive,
                           withXI: XI,
                           withXO: .inactive,
                           withYI: YI,
                           withYO: .inactive,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: .inactive,
                           withLinkIn: LinkIn,
                           withLinkLoOut: .inactive,
                           withLinkHiOut: .inactive,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func outputVToBus() -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: .inactive,
                           withBI: BI,
                           withBO: .inactive,
                           withCO: .inactive,
                           withDI: DI,
                           withEO: .inactive,
                           withFI: FI,
                           withUI: UI,
                           withUO: .inactive,
                           withVI: VI,
                           withVO: .active,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: .inactive,
                           withXI: XI,
                           withXO: .inactive,
                           withYI: YI,
                           withYO: .inactive,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: .inactive,
                           withLinkIn: LinkIn,
                           withLinkLoOut: .inactive,
                           withLinkHiOut: .inactive,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func outputPToBus() -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: .inactive,
                           withBI: BI,
                           withBO: .inactive,
                           withCO: .inactive,
                           withDI: DI,
                           withEO: .inactive,
                           withFI: FI,
                           withUI: UI,
                           withUO: .inactive,
                           withVI: VI,
                           withVO: .inactive,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: .active,
                           withXI: XI,
                           withXO: .inactive,
                           withYI: YI,
                           withYO: .inactive,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: .inactive,
                           withLinkIn: LinkIn,
                           withLinkLoOut: .inactive,
                           withLinkHiOut: .inactive,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func outputXToBus() -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: .inactive,
                           withBI: BI,
                           withBO: .inactive,
                           withCO: .inactive,
                           withDI: DI,
                           withEO: .inactive,
                           withFI: FI,
                           withUI: UI,
                           withUO: .inactive,
                           withVI: VI,
                           withVO: .inactive,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: .inactive,
                           withXI: XI,
                           withXO: .active,
                           withYI: YI,
                           withYO: .inactive,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: .inactive,
                           withLinkIn: LinkIn,
                           withLinkLoOut: .inactive,
                           withLinkHiOut: .inactive,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func outputYToBus() -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: .inactive,
                           withBI: BI,
                           withBO: .inactive,
                           withCO: .inactive,
                           withDI: DI,
                           withEO: .inactive,
                           withFI: FI,
                           withUI: UI,
                           withUO: .inactive,
                           withVI: VI,
                           withVO: .inactive,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: .inactive,
                           withXI: XI,
                           withXO: .inactive,
                           withYI: YI,
                           withYO: .active,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: .inactive,
                           withLinkIn: LinkIn,
                           withLinkLoOut: .inactive,
                           withLinkHiOut: .inactive,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func outputMToBus() -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: .inactive,
                           withBI: BI,
                           withBO: .inactive,
                           withCO: .inactive,
                           withDI: DI,
                           withEO: .inactive,
                           withFI: FI,
                           withUI: UI,
                           withUO: .inactive,
                           withVI: VI,
                           withVO: .inactive,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: .inactive,
                           withXI: XI,
                           withXO: .inactive,
                           withYI: YI,
                           withYO: .inactive,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: .active,
                           withLinkIn: LinkIn,
                           withLinkLoOut: .inactive,
                           withLinkHiOut: .inactive,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func outputLinkLoToBus() -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: .inactive,
                           withBI: BI,
                           withBO: .inactive,
                           withCO: .inactive,
                           withDI: DI,
                           withEO: .inactive,
                           withFI: FI,
                           withUI: UI,
                           withUO: .inactive,
                           withVI: VI,
                           withVO: .inactive,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: .inactive,
                           withXI: XI,
                           withXO: .inactive,
                           withYI: YI,
                           withYO: .inactive,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: .inactive,
                           withLinkIn: LinkIn,
                           withLinkLoOut: .active,
                           withLinkHiOut: .inactive,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func outputLinkHiToBus() -> ControlWord {
        return ControlWord(withAI: AI,
                           withAO: .inactive,
                           withBI: BI,
                           withBO: .inactive,
                           withCO: .inactive,
                           withDI: DI,
                           withEO: .inactive,
                           withFI: FI,
                           withUI: UI,
                           withUO: .inactive,
                           withVI: VI,
                           withVO: .inactive,
                           withUVInc: UVInc,
                           withPI: PI,
                           withPO: .inactive,
                           withXI: XI,
                           withXO: .inactive,
                           withYI: YI,
                           withYO: .inactive,
                           withXYInc: XYInc,
                           withMI: MI,
                           withMO: .inactive,
                           withLinkIn: LinkIn,
                           withLinkLoOut: .inactive,
                           withLinkHiOut: .active,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func inputAFromBus() -> ControlWord {
        return ControlWord(withAI: .active,
                           withAO: AO,
                           withBI: .inactive,
                           withBO: BO,
                           withCO: CO,
                           withDI: .inactive,
                           withEO: EO,
                           withFI: FI,
                           withUI: .inactive,
                           withUO: UO,
                           withVI: .inactive,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: .inactive,
                           withPO: PO,
                           withXI: .inactive,
                           withXO: XO,
                           withYI: .inactive,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: .inactive,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func inputBFromBus() -> ControlWord {
        return ControlWord(withAI: .inactive,
                           withAO: AO,
                           withBI: .active,
                           withBO: BO,
                           withCO: CO,
                           withDI: .inactive,
                           withEO: EO,
                           withFI: FI,
                           withUI: .inactive,
                           withUO: UO,
                           withVI: .inactive,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: .inactive,
                           withPO: PO,
                           withXI: .inactive,
                           withXO: XO,
                           withYI: .inactive,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: .inactive,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func inputDFromBus() -> ControlWord {
        return ControlWord(withAI: .inactive,
                           withAO: AO,
                           withBI: .inactive,
                           withBO: BO,
                           withCO: CO,
                           withDI: .active,
                           withEO: EO,
                           withFI: FI,
                           withUI: .inactive,
                           withUO: UO,
                           withVI: .inactive,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: .inactive,
                           withPO: PO,
                           withXI: .inactive,
                           withXO: XO,
                           withYI: .inactive,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: .inactive,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func inputUFromBus() -> ControlWord {
        return ControlWord(withAI: .inactive,
                           withAO: AO,
                           withBI: .inactive,
                           withBO: BO,
                           withCO: CO,
                           withDI: .inactive,
                           withEO: EO,
                           withFI: FI,
                           withUI: .active,
                           withUO: UO,
                           withVI: .inactive,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: .inactive,
                           withPO: PO,
                           withXI: .inactive,
                           withXO: XO,
                           withYI: .inactive,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: .inactive,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func inputVFromBus() -> ControlWord {
        return ControlWord(withAI: .inactive,
                           withAO: AO,
                           withBI: .inactive,
                           withBO: BO,
                           withCO: CO,
                           withDI: .inactive,
                           withEO: EO,
                           withFI: FI,
                           withUI: .inactive,
                           withUO: UO,
                           withVI: .active,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: .inactive,
                           withPO: PO,
                           withXI: .inactive,
                           withXO: XO,
                           withYI: .inactive,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: .inactive,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func inputPFromBus() -> ControlWord {
        return ControlWord(withAI: .inactive,
                           withAO: AO,
                           withBI: .inactive,
                           withBO: BO,
                           withCO: CO,
                           withDI: .inactive,
                           withEO: EO,
                           withFI: FI,
                           withUI: .inactive,
                           withUO: UO,
                           withVI: .inactive,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: .active,
                           withPO: PO,
                           withXI: .inactive,
                           withXO: XO,
                           withYI: .inactive,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: .inactive,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func inputXFromBus() -> ControlWord {
        return ControlWord(withAI: .inactive,
                           withAO: AO,
                           withBI: .inactive,
                           withBO: BO,
                           withCO: CO,
                           withDI: .inactive,
                           withEO: EO,
                           withFI: FI,
                           withUI: .inactive,
                           withUO: UO,
                           withVI: .inactive,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: .inactive,
                           withPO: PO,
                           withXI: .active,
                           withXO: XO,
                           withYI: .inactive,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: .inactive,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func inputYFromBus() -> ControlWord {
        return ControlWord(withAI: .inactive,
                           withAO: AO,
                           withBI: .inactive,
                           withBO: BO,
                           withCO: CO,
                           withDI: .inactive,
                           withEO: EO,
                           withFI: FI,
                           withUI: .inactive,
                           withUO: UO,
                           withVI: .inactive,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: .inactive,
                           withPO: PO,
                           withXI: .inactive,
                           withXO: XO,
                           withYI: .active,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: .inactive,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func inputMFromBus() -> ControlWord {
        return ControlWord(withAI: .inactive,
                           withAO: AO,
                           withBI: .inactive,
                           withBO: BO,
                           withCO: CO,
                           withDI: .inactive,
                           withEO: EO,
                           withFI: FI,
                           withUI: .inactive,
                           withUO: UO,
                           withVI: .inactive,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: .inactive,
                           withPO: PO,
                           withXI: .inactive,
                           withXO: XO,
                           withYI: .inactive,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: .active,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    func inputUVFromBus() -> ControlWord {
        return ControlWord(withAI: .inactive,
                           withAO: AO,
                           withBI: .inactive,
                           withBO: BO,
                           withCO: CO,
                           withDI: .inactive,
                           withEO: EO,
                           withFI: FI,
                           withUI: .active,
                           withUO: UO,
                           withVI: .active,
                           withVO: VO,
                           withUVInc: UVInc,
                           withPI: .inactive,
                           withPO: PO,
                           withXI: .inactive,
                           withXO: XO,
                           withYI: .inactive,
                           withYO: YO,
                           withXYInc: XYInc,
                           withMI: .inactive,
                           withMO: MO,
                           withLinkIn: LinkIn,
                           withLinkLoOut: LinkLoOut,
                           withLinkHiOut: LinkHiOut,
                           withJ: J,
                           withCarryIn: CarryIn,
                           withHLT: HLT)
    }
    
    public static func ==(lhs: ControlWord, rhs: ControlWord) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? ControlWord else { return false }
        guard unsignedIntegerValue == rhs.unsignedIntegerValue else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(unsignedIntegerValue)
        return hasher.finalize()
    }
}
