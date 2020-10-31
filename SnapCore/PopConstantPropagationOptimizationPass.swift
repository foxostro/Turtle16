//
//  PopConstantPropagationOptimizationPass.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class PopConstantPropagationOptimizationPass: NSObject {
    public var unoptimizedProgram = PopBasicBlock()
    public var optimizedProgram = PopBasicBlock()
    public enum CellState: Equatable { case known(UInt8), unknown }
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
    
    public func optimize() {
        optimizedProgram = unoptimizedProgram.compactMap { rewrite($0) }
    }
    
    fileprivate func invalidateAll() {
        invalidateMemory()
        registers = [
            .A : .unknown,
            .B : .unknown,
            .C : .unknown,
            .D : .unknown,
            .X : .unknown,
            .Y : .unknown,
            .U : .unknown,
            .V : .unknown
        ]
    }
    
    public func rewrite(_ instruction: PopInstruction) -> PopInstruction {
        switch instruction {
        case .li(let dst, let immediate):
            defer {
                setRegisterContents(dst: dst, value: UInt8(immediate))
            }
            if case .known(let existingContents) = getRegisterContents(dst) {
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

            case (.unknown, .known(let src)):
                return .li(dst, Int(src))

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
                    memory[Int(uv)] = .known(UInt8(immediate))
                } else {
                    invalidateMemory()
                }

            case .P:
                inxy()

            default:
                abort()
            }
            
        case .blt(let dst, _):
            if dst == .M {
                invalidateMemory()
            }
            inuv()
            inxy()
            
        case .add(let dst), .sub(let dst), .adc(let dst), .sbc(let dst), .dea(let dst), .dca(let dst), .and(let dst), .or(let dst), .xor(let dst), .lsl(let dst), .neg(let dst):
            setRegisterContents(dst: dst, state: .unknown)
            
        case .lixy, .jalr, .jmp, .jc, .jnc, .je, .jne, .jg, .jle, .jl, .jge:
            setRegisterContents(dst: .X, state: .unknown)
            setRegisterContents(dst: .Y, state: .unknown)
            
        case .copyLabel(let dst, _):
            memory[dst+0] = .unknown
            memory[dst+1] = .unknown
        
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
        } else if case .known(let v) = registers[.V] {
            registers[.V] = .known(UInt8(v &+ 1))
        } else {
            registers[.U] = .unknown
            registers[.V] = .unknown
        }
    }
    
    fileprivate func inxy() {
        if let xy: UInt16 = getPeripheralAddress() {
            let incremented = xy &+ 1
            let hi = UInt8((incremented >> 8) & 0xff)
            let lo = UInt8(incremented & 0xff)
            registers[.X] = .known(hi)
            registers[.Y] = .known(lo)
        } else if case .known(let y) = registers[.Y] {
            registers[.Y] = .known(UInt8(y &+ 1))
        } else {
            registers[.X] = .unknown
            registers[.Y] = .unknown
        }
    }
    
    fileprivate func setRegisterContents(dst: RegisterName, value: UInt8) {
        setRegisterContents(dst: dst, state: .known(value))
    }
    
    fileprivate func setRegisterContents(dst: RegisterName, state: CellState) {
        switch dst {
        case .A, .B, .C, .D, .U, .V, .X, .Y:
            registers[dst] = state
            
        case .UV:
            registers[.U] = state
            registers[.V] = state
        
        case .M:
            if let uv = getRamAddress() {
                memory[Int(uv)] = state
            } else {
                invalidateMemory()
            }
            
        default:
            break
        }
    }
    
    fileprivate func setRegisterContents(dst: RegisterName, src: RegisterName) {
        switch dst {
        case .A, .B, .C, .D, .U, .V, .X, .Y:
            switch src {
            case .M:
                if let uv = getRamAddress() {
                    registers[dst] = memory[Int(uv)]
                } else {
                    invalidateMemory()
                }
            
            default:
                registers[dst] = registers[src]
            }
            
        case .UV:
            setRegisterContents(dst: .U, src: src)
            setRegisterContents(dst: .V, src: src)
        
        case .M:
            if let uv = getRamAddress(), let knownValue = registers[src] {
                memory[Int(uv)] = knownValue
            } else {
                invalidateMemory()
            }
            
        default:
            break
        }
    }
    
    fileprivate func getRegisterContents(_ src: RegisterName) -> CellState {
        switch src {
        case .A, .B, .C, .D, .U, .V, .X, .Y:
            return registers[src] ?? .unknown
        
        case .M:
            if let uv = getRamAddress() {
                return memory[Int(uv)]
            }
            
        default:
            break
        }
        
        return .unknown
    }
    
    func getRamAddress() -> UInt16? {
        switch (registers[.U], registers[.V]) {
        case (.known(let u), .known(let v)):
            let uv = ((UInt16(u) & 0xff) << 8) + (UInt16(v) & 0xff)
            return uv
            
        default:
            return nil
        }
    }
    
    func getPeripheralAddress() -> UInt16? {
        switch (registers[.X], registers[.Y]) {
        case (.known(let x), .known(let y)):
            let xy = ((UInt16(x) & 0xff) << 8) + (UInt16(y) & 0xff)
            return xy
            
        default:
            return nil
        }
    }
    
    func invalidateMemory() {
        memory = Array<CellState>.init(repeating: .unknown, count: 65536)
    }
}
