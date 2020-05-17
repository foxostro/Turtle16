//
//  Chip74x181.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

// Simulates a single 74x181 ALU IC.
public class Chip74x181: NSObject {
    public var a:UInt8 = 0
    public var b:UInt8 = 0
    public var s:UInt8 = 0
    public var mode = 0
    public var carryIn = 0 // active-low
    public private(set) var carryOut = 0
    public private(set) var equalOut = 0
    public private(set) var result:UInt8 = 0
    
    // The actual hardware will update outputs as inputs change. However, in
    // the simulator, the outputs only update when the update method is called.
    public func update() {
        let cn = (carryIn != 0)
        let notM = !(mode != 0)
        
        let a0 = bit0(a)
        let a1 = bit1(a)
        let a2 = bit2(a)
        let a3 = bit3(a)
        
        let b0 = bit0(b)
        let b1 = bit1(b)
        let b2 = bit2(b)
        let b3 = bit3(b)
        
        let s0 = bit0(s)
        let s1 = bit1(s)
        let s2 = bit2(s)
        let s3 = bit3(s)
        
        let t0 = nor3(a0,
                      and2(b0, s0),
                      and2(s1, !b0))
        let t1 = nor2(and3(!b0, s2, a0),
                      and3(a0, b0, s3))
        let t2 = nor3(a1,
                      and2(b1, s0),
                      and2(s1, !b1))
        let t3 = nor2(and3(!b1, s2, a1),
                      and3(a1, s3, b1))
        let t4 = nor3(a2,
                      and2(b2, s0),
                      and2(s1, !b2))
        let t5 = nor2(and3(!b2, s2, a2),
                      and3(a2, s3, b2))
        let t6 = nor3(a3,
                      and2(b3, s0),
                      and2(s1, !b3))
        let t7 = nor2(and3(!b3, s2, a3),
                      and3(a3, s3, b3))
        
        let f0 = xor2(nand2(cn, notM),
                      xor2(t0, t1))
        let f1 = xor2(nor2(and2(notM, t0),
                           and3(notM, t1, cn)),
                      xor2(t2, t3))
        let f2 = xor2(nor3(and2(notM, t2),
                           and3(notM, t0, t3),
                           and4(notM, cn, t1, t3)),
                      xor2(t4, t5))
        let f3 = xor2(nor4(and2(notM, t4),
                           and3(notM, t2, t5),
                           and4(notM, t0, t3, t5),
                           and5(notM, cn, t1, t3, t5)),
                      xor2(t6, t7))
        
        let eq = and4(f0, f1, f2, f3)
        
        let cn4 = or2(and5(cn, t1, t3, t5, t7),
                      or4(and4(t0, t3, t5, t7),
                          and3(t2, t5, t7),
                          and2(t4, t7),
                          t6))
        
        result = makeResult(f0, f1, f2, f3)
        equalOut = eq ? 1 : 0
        carryOut = cn4 ? 1 : 0
    }
    
    func bit0(_ a: UInt8) -> Bool {
        return (a & 1) != 0
    }
    
    func bit1(_ a: UInt8) -> Bool {
        return ((a >> 1) & 1) != 0
    }
    
    func bit2(_ a: UInt8) -> Bool {
        return ((a >> 2) & 1) != 0
    }
    
    func bit3(_ a: UInt8) -> Bool {
        return ((a >> 3) & 1) != 0
    }
    
    func and2(_ a: Bool, _ b: Bool) -> Bool {
        return (a && b)
    }
    
    func and3(_ a: Bool, _ b: Bool, _ c: Bool) -> Bool {
        return (a && b && c)
    }
    
    func and4(_ a: Bool, _ b: Bool, _ c: Bool, _ d: Bool) -> Bool {
        return (a && b && c && d)
    }
    
    func and5(_ a: Bool, _ b: Bool, _ c: Bool, _ d: Bool, _ e: Bool) -> Bool {
        return (a && b && c && d && e)
    }
    
    func nand2(_ a: Bool, _ b: Bool) -> Bool {
        return !(a && b)
    }
    
    public func nand3(_ a: Bool, _ b: Bool, _ c: Bool) -> Bool {
        return !(a && b && c)
    }
    
    func nor2(_ a: Bool, _ b: Bool) -> Bool {
        return !(a || b)
    }
    
    func nor3(_ a: Bool, _ b: Bool, _ c: Bool) -> Bool {
        return !(a || b || c)
    }
    
    func nor4(_ a: Bool, _ b: Bool, _ c: Bool, _ d: Bool) -> Bool {
        return !(a || b || c || d)
    }
    
    func or2(_ a: Bool, _ b: Bool) -> Bool {
        return (a || b)
    }
    
    func or4(_ a: Bool, _ b: Bool, _ c: Bool, _ d: Bool) -> Bool {
        return (a || b || c || d)
    }
    
    public func xor2(_ a: Bool, _ b: Bool) -> Bool {
        if (a && !b) {
            return true
        } else if (!a && b) {
            return true
        }
        
        return false
    }
    
    func makeResult(_ f0:Bool, _ f1:Bool, _ f2:Bool, _ f3:Bool) -> UInt8 {
        var result:UInt8 = 0
        result += f0 ? 1 : 0
        result += f1 ? 2 : 0
        result += f2 ? 4 : 0
        result += f3 ? 8 : 0
        return result
    }
}
