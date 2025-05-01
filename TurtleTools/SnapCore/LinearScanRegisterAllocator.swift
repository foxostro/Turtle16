//
//  LinearScanRegisterAllocator.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/6/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

/// A standard Linear Scan Register Allocator.
/// Live Intervals which must be spilled are simply not assigned a register.
/// Spill code is inserted elsewhere.
/// Ignores live intervals in the input already assigned a physical register.
/// See <http://web.cs.ucla.edu/~palsberg/course/cs132/linearscan.pdf>
public struct LinearScanRegisterAllocator {
    private var registerPool: [Bool]
    private var registers: [Int: Int?] = [:]
    private var spillSlots: [Int: Int] = [:]
    private var active: [Int] = []
    private var nextSpillSlot = 0

    private let liveIntervals: [LiveInterval]
    private let increasingStartPoint: [LiveInterval]
    private let increasingEndPoint: [LiveInterval]

    public static func allocate(
        numRegisters: Int,
        liveIntervals: [LiveInterval]
    ) -> [LiveInterval] {
        var allocator = LinearScanRegisterAllocator(numRegisters, liveIntervals)
        allocator.performAllocation()
        let result = allocator.collateResults()
        return result
    }

    private init(_ numRegisters: Int, _ liveIntervals: [LiveInterval]) {
        assert(numRegisters >= 0)
        self.registerPool = [Bool](repeating: true, count: numRegisters)
        self.liveIntervals = liveIntervals
        increasingStartPoint = liveIntervals.sorted { leftRange, rightRange in
            leftRange.range.startIndex < rightRange.range.startIndex
        }
        increasingEndPoint = liveIntervals.sorted { leftRange, rightRange in
            leftRange.range.endIndex < rightRange.range.endIndex
        }
    }

    private mutating func performAllocation() {
        for i in 0..<increasingStartPoint.count {
            expireOldIntervals(i)
            guard liveIntervals[i].physicalRegisterName == nil else { continue }
            if active.count == registerPool.count {
                spillAtInterval(i)
            }
            else {
                registers[i] = allocatePhysicalRegister()!
                addToActive(i)
            }
        }
    }

    private mutating func expireOldIntervals(_ i: Int) {
        for j in active {
            guard liveIntervals[j].range.endIndex <= liveIntervals[i].range.startIndex else {
                return
            }
            removeFromActive(j)
            freePhysicalRegister(j)
        }
    }

    private mutating func spillAtInterval(_ i: Int) {
        if let spill = active.last,
            liveIntervals[spill].range.endIndex > liveIntervals[i].range.endIndex
        {
            registers[i] = registers[spill]
            registers[spill] = nil
            removeFromActive(spill)
            addToActive(i)
            spillSlots[spill] = getNextSpillSlot()
        }
        else {
            registers[i] = nil
            spillSlots[i] = getNextSpillSlot()
        }
    }

    private mutating func removeFromActive(_ i: Int) {
        active.removeAll(where: { $0 == i })
    }

    private mutating func addToActive(_ i: Int) {
        active.append(i)
        active.sort { leftIndex, rightIndex in
            liveIntervals[leftIndex].range.endIndex < liveIntervals[rightIndex].range.endIndex
        }
    }

    private mutating func getNextSpillSlot() -> Int {
        let result = nextSpillSlot
        nextSpillSlot += 1
        return result
    }

    private mutating func allocatePhysicalRegister() -> Int? {
        for i in 0..<registerPool.count {
            if registerPool[i] {
                registerPool[i] = false
                return i
            }
        }
        return nil  // unreachable?
    }

    private mutating func freePhysicalRegister(_ j: Int) {
        if let r_ = registers[j], let r = r_ {
            registerPool[r] = true
        }
    }

    private func collateResults() -> [LiveInterval] {
        var result: [LiveInterval] = []
        for i in 0..<liveIntervals.count {
            let liveInterval = liveIntervals[i]
            let physicalRegisterName: String?
            if let name = liveInterval.physicalRegisterName {
                physicalRegisterName = name
            }
            else if let index = (registers[i] ?? nil) {
                physicalRegisterName = "r\(index)"
            }
            else {
                physicalRegisterName = nil
            }
            result.append(
                LiveInterval(
                    range: liveInterval.range,
                    virtualRegisterName: liveInterval.virtualRegisterName,
                    physicalRegisterName: physicalRegisterName,
                    spillSlot: spillSlots[i]
                )
            )
        }
        return result
    }
}
