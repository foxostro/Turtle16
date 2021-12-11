//
//  LinearScanRegisterAllocator.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/6/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

// A standard Linear Scan Register Allocator.
// Live Intervals which must be spilled are simply not assigned a register.
// Spill code is inserted elsewhere.
// Configured for a pool of five registers {r0, r1, r2, r3, r4}
// Ignores live intervals in the input already assigned a physical register.
// See <http://web.cs.ucla.edu/~palsberg/course/cs132/linearscan.pdf>
public class LinearScanRegisterAllocator: NSObject {
    var registerPool: [Bool]
    var registers: [Int : Int?] = [:]
    var spillSlots: [Int : Int] = [:]
    var active: [Int] = []
    var nextSpillSlot = 0
    
    let liveIntervals: [LiveInterval]
    let increasingStartPoint: [LiveInterval]
    let increasingEndPoint: [LiveInterval]
    
    public static func allocate(numRegisters: Int,
                                liveIntervals: [LiveInterval]) -> [LiveInterval] {
        let allocator = LinearScanRegisterAllocator(numRegisters, liveIntervals)
        allocator.performAllocation()
        let result = allocator.collateResults()
        return result
    }
    
    init(_ numRegisters: Int, _ liveIntervals: [LiveInterval]) {
        assert(numRegisters >= 0)
        self.registerPool = Array<Bool>(repeating: true, count: numRegisters)
        self.liveIntervals = liveIntervals
        increasingStartPoint = liveIntervals.sorted(by: { leftRange, rightRange in
            leftRange.range.startIndex < rightRange.range.startIndex
        })
        increasingEndPoint = liveIntervals.sorted(by: { leftRange, rightRange in
            leftRange.range.endIndex < rightRange.range.endIndex
        })
    }
    
    func performAllocation() {
        for i in 0..<increasingStartPoint.count {
            expireOldIntervals(i)
            if liveIntervals[i].physicalRegisterName != nil {
                continue
            }
            if active.count == registerPool.count {
                spillAtInterval(i)
            } else {
                registers[i] = allocatePhysicalRegister()!
                addToActive(i)
            }
        }
    }
    
    func expireOldIntervals(_ i: Int) {
        for j in Array(active) {
            if liveIntervals[j].range.endIndex > liveIntervals[i].range.startIndex {
                return
            }
            removeFromActive(j)
            freePhysicalRegister(j)
        }
    }
    
    func spillAtInterval(_ i: Int) {
        if let spill = active.last, liveIntervals[spill].range.endIndex > liveIntervals[i].range.endIndex {
            registers[i] = registers[spill]
            registers[spill] = nil
            removeFromActive(spill)
            addToActive(i)
            spillSlots[spill] = getNextSpillSlot()
        } else {
            registers[i] = nil
            spillSlots[i] = getNextSpillSlot()
        }
    }
    
    func removeFromActive(_ i: Int) {
        active.removeAll(where: { $0 == i })
    }
    
    func addToActive(_ i: Int) {
        active.append(i)
        active.sort { leftIndex, rightIndex in
            liveIntervals[leftIndex].range.endIndex < liveIntervals[rightIndex].range.endIndex
        }
    }
    
    func getNextSpillSlot() -> Int {
        let result = nextSpillSlot
        nextSpillSlot += 1
        return result
    }
    
    func allocatePhysicalRegister() -> Int? {
        for i in 0..<registerPool.count {
            if registerPool[i] {
                registerPool[i] = false
                return i
            }
        }
        return nil // unreachable?
    }
    
    func freePhysicalRegister(_ j: Int) {
        if let r_ = registers[j], let r = r_ {
            registerPool[r] = true
        }
    }
    
    func collateResults() -> [LiveInterval] {
        var result: [LiveInterval] = []
        for i in 0..<liveIntervals.count {
            let liveInterval = liveIntervals[i]
            let physicalRegisterName: String?
            if let name = liveInterval.physicalRegisterName {
                physicalRegisterName = name
            }
            else if let index = (registers[i] ?? nil)  {
                physicalRegisterName = "r\(index)"
            }
            else {
                physicalRegisterName = nil
            }
            result.append(LiveInterval(range: liveInterval.range,
                                       virtualRegisterName: liveInterval.virtualRegisterName,
                                       physicalRegisterName: physicalRegisterName,
                                       spillSlot: spillSlots[i]))
        }
        return result
    }
}
