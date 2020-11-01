//
//  PopConstantPropagationOptimizationPass.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class PopConstantPropagationOptimizationPass: NSObject {
    public let shouldCheckForDivergenceForDebugging = false
    public var unoptimizedProgram = PopBasicBlock()
    public var optimizedProgram = PopBasicBlock()
    public enum CellState: Equatable, Hashable {
        case known(UInt8), unknown
        
        public var description: String {
            switch self {
            case .known(let value):
                return toHex2(value)
                
            case .unknown:
                return "unknown"
            }
        }
        
        func toHex2(_ value: UInt8) -> String {
            return String(format: "0x%02x", value)
        }
    }
    public class State: NSObject {
        public var memory = Array<CellState>.init(repeating: .unknown, count: 65536)
        public var registers: [RegisterName : CellState] = [
            .A : .unknown,
            .B : .unknown,
            .D : .unknown,
            .X : .unknown,
            .Y : .unknown,
            .U : .unknown,
            .V : .unknown
        ]
        
        func invalidateAll() {
            invalidateMemory()
            registers = [
                .A : .unknown,
                .B : .unknown,
                .D : .unknown,
                .X : .unknown,
                .Y : .unknown,
                .U : .unknown,
                .V : .unknown
            ]
        }
        
        func invalidateMemory() {
            memory = Array<CellState>.init(repeating: .unknown, count: 65536)
        }
        
        func copy() -> State {
            let theCopy = State()
            theCopy.memory = memory
            theCopy.registers = registers
            return theCopy
        }
        
        open override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else {
                return false
            }
            guard type(of: rhs!) == type(of: self) else {
                return false
            }
            guard let rhs = rhs as? State else {
                return false
            }
            guard memory == rhs.memory else {
                return false
            }
            guard registers == rhs.registers else {
                return false
            }
            return true
        }
        
        open override var hash: Int {
            var hasher = Hasher()
            hasher.combine(memory)
            hasher.combine(registers)
            return hasher.finalize()
        }
        
        func diff(_ other: State) -> String {
            var result = ""
            for i in 0..<65536 {
                let expected = memory[i]
                let actual = other.memory[i]
                if expected != actual {
                    result += "\nmemory[\(toHex4(i))] = \(actual) ; expected \(expected)"
                }
            }
            for key in registers.keys {
                let expected = registers[key]!
                let actual = other.registers[key]!
                if expected != actual {
                    result += "\nregisters[\(key)] = \(actual) ; expected \(expected)"
                }
            }
            return result
        }
        
        fileprivate func toHex4(_ value: Int) -> String {
            return String(format: "0x%04x", value)
        }
    }
    public let state = State()
    
    public func optimize() {
        var unoptimizedStateProgression: [State] = []
        
        if shouldCheckForDivergenceForDebugging {
            unoptimizedStateProgression = unoptimizedProgram.map { (instruction: PopInstruction) -> State in
                _ = rewrite(instruction)
                return state.copy()
            }
        }
        
        state.invalidateAll()
        
        optimizedProgram = unoptimizedProgram.map {
            let modifiedInstruction = rewrite($0)
            if shouldCheckForDivergenceForDebugging {
                let reference = unoptimizedStateProgression.removeFirst()
                if state != reference {
                    print("divergent state:\n\(reference.diff(state))")
                }
            }
            return modifiedInstruction
        }
    }
    
    public func rewrite(_ instruction: PopInstruction) -> PopInstruction {
        switch instruction {
        case .li(let dst, let immediate):
            defer {
                setRegisterContents(dst: dst, value: UInt8(immediate))
            }
            if dst == .UV {
                // do nothing
            }
            else if case .known(let existingContents) = getRegisterContents(dst) {
                if existingContents == UInt8(immediate) {
                    return .fake
                }
            }
        
        case .mov(let dst, let src):
            defer {
                setRegisterContents(dst: dst, src: src)
            }
            let valueOfSource = getRegisterContents(src)
            let valueOfDestination = getRegisterContents(dst)

            switch (valueOfDestination, valueOfSource) {
            case (.known(let dst), .known(let src)):
                if dst == src {
                    return .fake
                }

            case (.unknown, .known(let srcValue)):
                if dst == .M && src == .B {
                    break // TODO: this case is a hack which hides an underlying bug
                } else if dst == .Y && src == .B {
                    break // TODO: this case is a hack which hides an underlying bug
                } else {
                    return .li(dst, Int(srcValue))
                }

            default:
                break
            }
            
        case .inuv:
            inuv()
            
        case .inxy:
            inxy()
            
        case .blti(let dst, let immediate):
            switch dst {
            case .M:
                inuv()
                if let uv = getRamAddress() {
                    state.memory[Int(uv)] = .known(UInt8(immediate))
                } else {
                    state.invalidateMemory()
                }

            case .P:
                inxy()

            default:
                break
            }
            
        case .blt(let dst, _):
            if dst == .M {
                state.invalidateMemory()
            }
            inuv()
            inxy()
            
        case .add(let dst), .sub(let dst), .adc(let dst), .sbc(let dst), .dea(let dst), .dca(let dst), .and(let dst), .or(let dst), .xor(let dst), .lsl(let dst), .neg(let dst):
            setRegisterContents(dst: dst, state: .unknown)
            
        case .lixy, .jalr, .jmp, .jc, .jnc, .je, .jne, .jg, .jle, .jl, .jge:
            setRegisterContents(dst: .X, state: .unknown)
            setRegisterContents(dst: .Y, state: .unknown)
            
        case .copyLabel(let dst, _):
            state.memory[dst+0] = .unknown
            state.memory[dst+1] = .unknown
        
        default:
            break
        }
        
        return instruction
    }
    
    fileprivate func inuv() {
        if let uv: UInt16 = getRamAddress() {
            let incremented = uv &+ 1
            let hi = UInt8((incremented >> 8) & 0xff)
            let lo = UInt8(incremented & 0xff)
            setRegisterContents(dst: .U, value: hi)
            setRegisterContents(dst: .V, value: lo)
        } else if case .known(let v) = state.registers[.V] {
            state.registers[.V] = .known(UInt8(v &+ 1))
        } else {
            state.registers[.U] = .unknown
            state.registers[.V] = .unknown
        }
    }
    
    fileprivate func inxy() {
        if let xy: UInt16 = getPeripheralAddress() {
            let incremented = xy &+ 1
            let hi = UInt8((incremented >> 8) & 0xff)
            let lo = UInt8(incremented & 0xff)
            state.registers[.X] = .known(hi)
            state.registers[.Y] = .known(lo)
        } else if case .known(let y) = state.registers[.Y] {
            state.registers[.Y] = .known(UInt8(y &+ 1))
        } else {
            state.registers[.X] = .unknown
            state.registers[.Y] = .unknown
        }
    }
    
    fileprivate func setRegisterContents(dst: RegisterName, value: UInt8) {
        setRegisterContents(dst: dst, state: .known(value))
    }
    
    fileprivate func setRegisterContents(dst: RegisterName, state cellState: CellState) {
        switch dst {
        case .A, .B, .D, .U, .V, .X, .Y:
            state.registers[dst] = cellState
            
        case .UV:
            state.registers[.U] = cellState
            state.registers[.V] = cellState
        
        case .M:
            if let uv = getRamAddress() {
                state.memory[Int(uv)] = cellState
            } else {
                state.invalidateMemory()
            }
            
        default:
            break
        }
    }
    
    fileprivate func setRegisterContents(dst: RegisterName, src: RegisterName) {
        switch dst {
        case .A, .B, .D, .U, .V, .X, .Y:
            switch src {
            case .M:
                if let uv = getRamAddress() {
                    state.registers[dst] = state.memory[Int(uv)]
                } else {
                    state.registers[dst] = .unknown
                    state.invalidateMemory()
                }
            
            default:
                state.registers[dst] = state.registers[src]
            }
            
        case .UV:
            setRegisterContents(dst: .U, src: src)
            setRegisterContents(dst: .V, src: src)
        
        case .M:
            if let uv = getRamAddress(), let knownValue = state.registers[src] {
                state.memory[Int(uv)] = knownValue
            } else {
                state.invalidateMemory()
            }
            
        default:
            break
        }
    }
    
    fileprivate func getRegisterContents(_ src: RegisterName) -> CellState {
        switch src {
        case .A, .B, .D, .U, .V, .X, .Y:
            return state.registers[src] ?? .unknown
        
        case .M:
            if let uv = getRamAddress() {
                return state.memory[Int(uv)]
            }
            
        default:
            break
        }
        
        return .unknown
    }
    
    func getRamAddress() -> UInt16? {
        switch (state.registers[.U], state.registers[.V]) {
        case (.known(let u), .known(let v)):
            let uv = ((UInt16(u) & 0xff) << 8) + (UInt16(v) & 0xff)
            return uv
            
        default:
            return nil
        }
    }
    
    func getPeripheralAddress() -> UInt16? {
        switch (state.registers[.X], state.registers[.Y]) {
        case (.known(let x), .known(let y)):
            let xy = ((UInt16(x) & 0xff) << 8) + (UInt16(y) & 0xff)
            return xy
            
        default:
            return nil
        }
    }
}
