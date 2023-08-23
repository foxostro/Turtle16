//
//  TackToTurtle16Compiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/19/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import Turtle16SimulatorCore

public class TackToTurtle16Compiler: SnapASTTransformerBase {
    public override func compile(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        return flatten(try super.compile(node0))
    }
    
    fileprivate func flatten(_ node: AbstractSyntaxTreeNode?) -> AbstractSyntaxTreeNode {
        return try! SnapASTTransformerFlattenSeq().compile(node) ?? Seq(sourceAnchor: node?.sourceAnchor, children: [])
    }
    
    fileprivate var nextRegisterIndex = 0
    
    fileprivate func nextRegister() -> String {
        let index = nextRegisterIndex
        nextRegisterIndex = nextRegisterIndex + 1
        return "vr\(index)"
    }
    
    fileprivate var registerMap: [TackInstruction.Register : String] = [:]
    
    fileprivate func corresponding(_ tackRegister: TackInstruction.Register) -> ParameterIdentifier {
        let asmRegister: String
        switch tackRegister {
        case .w(.sp):
            asmRegister = "sp"
            
        case .w(.fp):
            asmRegister = "fp"
            
        case .w(.ra):
            asmRegister = "ra"
            
        case .w(.w(_)), .b(.b(_)):
            if let r = registerMap[tackRegister] {
                asmRegister = r
            } else {
                asmRegister = nextRegister()
                registerMap[tackRegister] = asmRegister
            }
        }
        return ParameterIdentifier(asmRegister)
    }
    
    public override func compile(tack node: TackInstructionNode) throws -> AbstractSyntaxTreeNode? {
        let anc = node.sourceAnchor
        switch node.instruction {
        case .nop: return nop(node)
        case .hlt: return hlt(node)
        case .call(let target): return call(anc, target)
        case .callptr(let target): return callptr(anc, target)
        case .enter(let count): return enter(anc, count)
        case .leave: return leave(anc)
        case .ret: return ret(anc)
        case .jmp(let target): return jmp(anc, target)
        case .la(let dst, let label): return la(anc, dst, label)
        case .ststr(let dst, let str): return ststr(anc, dst, str)
        case .memcpy(let dst, let src, let numberOfWords): return memcpy(anc, dst, src, numberOfWords)
        case .alloca(let dst, let numberOfWords): return alloca(anc, dst, numberOfWords)
        case .free(let numberOfWords): return free(anc, numberOfWords)
        case .inlineAssembly(let asm): return try inlineAssembly(asm)
        case .syscall(let n, let ptr): return syscall(anc, n, ptr)
        
        case .bz(let test, let target): return bz(anc, test, target)
        case .bnz(let test, let target): return bnz(anc, test, target)
            
        case .load16(let dst, let addr, let offset): return load16(anc, dst, addr, offset)
        case .store16(let src, let addr, let offset): return store16(anc, src, addr, offset)
        case .andi16(let dst, let left, let imm): return andi16(anc, dst, left, imm)
        case .addi16(let dst, let left, let imm): return addi16(anc, dst, left, imm)
        case .subi16(let dst, let left, let imm): return subi16(anc, dst, left, imm)
        case .muli16(let dst, let left, let imm): return muli16(anc, dst, left, imm)
        case .li16(let dst, let imm): return li16(anc, dst, imm)
        case .liu16(let dst, let imm): return liu16(anc, dst, imm)
        case .and16(let c, let a, let b): return and16(anc, c, a, b)
        case .or16(let c, let a, let b): return or16(anc, c, a, b)
        case .xor16(let c, let a, let b): return xor16(anc, c, a, b)
        case .neg16(let dst, let src): return neg16(anc, dst, src)
        case .not16(let dst, let src): return not16(anc, dst, src)
        case .add16(let c, let a, let b): return add16(anc, c, a, b)
        case .sub16(let c, let a, let b): return sub16(anc, c, a, b)
        case .mul16(let c, let a, let b): return mul16(anc, c, a, b)
        case .div16(let c, let a, let b): return div16(anc, c, a, b)
        case .mod16(let c, let a, let b): return mod16(anc, c, a, b)
        case .lsl16(let c, let a, let b): return lsl16(anc, c, a, b)
        case .lsr16(let c, let a, let b): return lsr16(anc, c, a, b)
        case .eq16(let c, let a, let b): return eq16(anc, c, a, b)
        case .ne16(let c, let a, let b): return ne16(anc, c, a, b)
        case .lt16(let c, let a, let b): return lt16(anc, c, a, b)
        case .ge16(let c, let a, let b): return ge16(anc, c, a, b)
        case .le16(let c, let a, let b): return le16(anc, c, a, b)
        case .gt16(let c, let a, let b): return gt16(anc, c, a, b)
        case .ltu16(let c, let a, let b): return ltu16(anc, c, a, b)
        case .geu16(let c, let a, let b): return geu16(anc, c, a, b)
        case .leu16(let c, let a, let b): return leu16(anc, c, a, b)
        case .gtu16(let c, let a, let b): return gtu16(anc, c, a, b)
        
        case .load8(let dst, let addr, let offset): return load8(anc, dst, addr, offset)
        case .store8(let src, let addr, let offset): return store8(anc, src, addr, offset)
        case .li8(let dst, let imm): return li8(anc, dst, imm)
        case .liu8(let dst, let imm): return liu8(anc, dst, imm)
        case .and8(let c, let a, let b): return and8(anc, c, a, b)
        case .or8(let c, let a, let b): return or8(anc, c, a, b)
        case .xor8(let c, let a, let b): return xor8(anc, c, a, b)
        case .neg8(let dst, let src): return neg8(anc, dst, src)
        case .not8(let dst, let src): return not8(anc, dst, src)
        case .add8(let c, let a, let b): return add8(anc, c, a, b)
        case .sub8(let c, let a, let b): return sub8(anc, c, a, b)
        case .mul8(let c, let a, let b): return mul8(anc, c, a, b)
        case .div8(let c, let a, let b): return div8(anc, c, a, b)
        case .mod8(let c, let a, let b): return mod8(anc, c, a, b)
        case .lsl8(let c, let a, let b): return lsl8(anc, c, a, b)
        case .lsr8(let c, let a, let b): return lsr8(anc, c, a, b)
        case .eq8(let c, let a, let b): return eq8(anc, c, a, b)
        case .ne8(let c, let a, let b): return ne8(anc, c, a, b)
        case .lt8(let c, let a, let b): return lt8(anc, c, a, b)
        case .ge8(let c, let a, let b): return ge8(anc, c, a, b)
        case .le8(let c, let a, let b): return le8(anc, c, a, b)
        case .gt8(let c, let a, let b): return gt8(anc, c, a, b)
        case .ltu8(let c, let a, let b): return ltu8(anc, c, a, b)
        case .geu8(let c, let a, let b): return geu8(anc, c, a, b)
        case .leu8(let c, let a, let b): return leu8(anc, c, a, b)
        case .gtu8(let c, let a, let b): return gtu8(anc, c, a, b)
        case .movsbw(let dst, let src): return movsbw(anc, dst, src)
        case .movswb(let dst, let src): return movswb(anc, dst, src)
        case .movzwb(let dst, let src): return movzwb(anc, dst, src)
        case .movzbw(let dst, let src): return movzbw(anc, dst, src)
        }
    }
    
    func nop(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kNOP)
        ])
    }
    
    func hlt(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kNOP),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kHLT)
        ])
    }
    
    func call(_ sourceAnchor: SourceAnchor?, _ target: String) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: sourceAnchor,
                               instruction: kCALL,
                               parameter: ParameterIdentifier(target))
    }
    
    func callptr(_ sourceAnchor: SourceAnchor?, _ target: TackInstruction.RegisterPointer) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: sourceAnchor,
                               instruction: kCALLPTR,
                               parameter: corresponding(.w(target)))
    }
    
    func enter(_ sourceAnchor: SourceAnchor?, _ count: Int) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: sourceAnchor, instruction: kENTER, parameter: ParameterNumber(count))
    }
    
    func leave(_ sourceAnchor: SourceAnchor?) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: sourceAnchor, instruction: kLEAVE)
    }
    
    func ret(_ sourceAnchor: SourceAnchor?) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: sourceAnchor, instruction: kRET)
    }
    
    func jmp(_ sourceAnchor: SourceAnchor?, _ target: String) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: sourceAnchor, instruction: kJMP, parameter: ParameterIdentifier(target))
    }
    
    func not16(_ sourceAnchor: SourceAnchor?, _ dst_: TackInstruction.Register16, _ src_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let src = corresponding(.w(src_))
        let tmp = ParameterIdentifier(nextRegister())
        let dst = corresponding(.w(dst_))
        
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kNOT, parameters: [tmp, src ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kANDI, parameters: [dst, tmp, ParameterNumber(1)])
        ])
    }
    
    func not8(_ sourceAnchor: SourceAnchor?, _ dst_: TackInstruction.Register8, _ src_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let src = corresponding(.b(src_))
        let tmp = ParameterIdentifier(nextRegister())
        let dst = corresponding(.b(dst_))
        
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kNOT, parameters: [tmp, src ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kANDI, parameters: [dst, tmp, ParameterNumber(1)])
        ])
    }
    
    func la(_ sourceAnchor: SourceAnchor?, _ dst_: TackInstruction.RegisterPointer, _ label: String) -> AbstractSyntaxTreeNode? {
        let dst = corresponding(.w(dst_))
        let tgt = ParameterIdentifier(label)
        let r = InstructionNode(sourceAnchor: sourceAnchor, instruction: kLA, parameters: [dst, tgt])
        return r
    }
    
    func bz(_ sourceAnchor: SourceAnchor?, _ test_: TackInstruction.RegisterBoolean, _ label: String) -> AbstractSyntaxTreeNode? {
        let test = corresponding(.w(test_))
        
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMPI, parameters: [
                test,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBEQ, parameters: [
                ParameterIdentifier(label)
            ])
        ])
    }
    
    func bnz(_ sourceAnchor: SourceAnchor?, _ test_: TackInstruction.RegisterBoolean, _ label: String) -> AbstractSyntaxTreeNode? {
        let test = corresponding(.w(test_))
        
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMPI, parameters: [
                test,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBNE, parameters: [
                ParameterIdentifier(label)
            ])
        ])
    }
    
    func load16(_ sourceAnchor: SourceAnchor?,
                _ dst_: TackInstruction.Register16,
                _ addr_: TackInstruction.RegisterPointer,
                _ imm: Int) -> AbstractSyntaxTreeNode? {
        if imm > 15 || imm < -16 {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let addr1 = corresponding(.w(addr_))
            let offset = nextRegister()
            let addr2 = nextRegister()
            let dst = corresponding(.w(dst_))
            
            return Seq(sourceAnchor: sourceAnchor, children: [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters:[
                    ParameterIdentifier(offset),
                    ParameterNumber(Int(imm16 & 0x00ff))
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters:[
                    ParameterIdentifier(offset),
                    ParameterNumber(Int((imm16 & 0xff00) >> 8))
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kADD, parameters:[
                    ParameterIdentifier(addr2),
                    ParameterIdentifier(offset),
                    addr1
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLOAD, parameters:[
                    dst,
                    ParameterIdentifier(addr2)
                ])
            ])
        }
        else {
            let addr = corresponding(.w(addr_))
            let dst = corresponding(.w(dst_))
            return InstructionNode(sourceAnchor: sourceAnchor, instruction: kLOAD, parameters: [
                dst,
                addr,
                ParameterNumber(imm)
            ])
        }
    }
    
    func load8(_ sourceAnchor: SourceAnchor?,
               _ dst_: TackInstruction.Register8,
               _ addr_: TackInstruction.RegisterPointer,
               _ imm: Int) -> AbstractSyntaxTreeNode? {
        if imm > 15 || imm < -16 {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let addr1 = corresponding(.w(addr_))
            let offset = nextRegister()
            let addr2 = nextRegister()
            let dst = corresponding(.b(dst_))
            
            return Seq(sourceAnchor: sourceAnchor, children: [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters:[
                    ParameterIdentifier(offset),
                    ParameterNumber(Int(imm16 & 0x00ff))
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters:[
                    ParameterIdentifier(offset),
                    ParameterNumber(Int((imm16 & 0xff00) >> 8))
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kADD, parameters:[
                    ParameterIdentifier(addr2),
                    ParameterIdentifier(offset),
                    addr1
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLOAD, parameters:[
                    dst,
                    ParameterIdentifier(addr2)
                ])
            ])
        }
        else {
            let addr = corresponding(.w(addr_))
            let dst = corresponding(.b(dst_))
            return InstructionNode(sourceAnchor: sourceAnchor, instruction: kLOAD, parameters: [
                dst,
                addr,
                ParameterNumber(imm)
            ])
        }
    }
    
    func store16(_ sourceAnchor: SourceAnchor?,
                 _ src_: TackInstruction.Register16,
                 _ addr_: TackInstruction.RegisterPointer,
                 _ imm: Int) -> AbstractSyntaxTreeNode? {
        if imm > 15 || imm < -16 {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let addr1 = corresponding(.w(addr_))
            let offset = nextRegister()
            let addr2 = nextRegister()
            let src = corresponding(.w(src_))
            
            return Seq(sourceAnchor: sourceAnchor, children: [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters:[
                    ParameterIdentifier(offset),
                    ParameterNumber(Int(imm16 & 0x00ff))
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters:[
                    ParameterIdentifier(offset),
                    ParameterNumber(Int((imm16 & 0xff00) >> 8))
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kADD, parameters:[
                    ParameterIdentifier(addr2),
                    ParameterIdentifier(offset),
                    addr1
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kSTORE, parameters:[
                    src,
                    ParameterIdentifier(addr2)
                ])
            ])
        }
        else {
            let addr = corresponding(.w(addr_))
            let src = corresponding(.w(src_))
            return InstructionNode(sourceAnchor: sourceAnchor, instruction: kSTORE, parameters: [
                src,
                addr,
                ParameterNumber(imm)
            ])
        }
    }
    
    func store8(_ sourceAnchor: SourceAnchor?,
                _ src_: TackInstruction.Register8,
                _ addr_: TackInstruction.RegisterPointer,
                _ imm: Int) -> AbstractSyntaxTreeNode? {
        if imm > 15 || imm < -16 {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let addr1 = corresponding(.w(addr_))
            let offset = nextRegister()
            let addr2 = nextRegister()
            let src = corresponding(.b(src_))
            
            return Seq(sourceAnchor: sourceAnchor, children: [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters:[
                    ParameterIdentifier(offset),
                    ParameterNumber(Int(imm16 & 0x00ff))
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters:[
                    ParameterIdentifier(offset),
                    ParameterNumber(Int((imm16 & 0xff00) >> 8))
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kADD, parameters:[
                    ParameterIdentifier(addr2),
                    ParameterIdentifier(offset),
                    addr1
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kSTORE, parameters:[
                    src,
                    ParameterIdentifier(addr2)
                ])
            ])
        }
        else {
            let addr = corresponding(.w(addr_))
            let src = corresponding(.b(src_))
            return InstructionNode(sourceAnchor: sourceAnchor, instruction: kSTORE, parameters: [
                src,
                addr,
                ParameterNumber(imm)
            ])
        }
    }
    
    func ststr(_ sourceAnchor: SourceAnchor?,
               _ dst_: TackInstruction.RegisterPointer,
               _ str: String) -> AbstractSyntaxTreeNode? {
        // TODO: Use the offset parameter of the STORE instruction to improve STSTR performance.
                let originalDst = corresponding(.w(dst_))
        let dst = ParameterIdentifier(nextRegister())
        let src = ParameterIdentifier(nextRegister())
        var children: [AbstractSyntaxTreeNode] = [
            InstructionNode(sourceAnchor: sourceAnchor,
                            instruction: kADDI,
                            parameters: [dst, originalDst, ParameterNumber(0)])
        ]
        if str == "" {
            return nil
        }
        for character in str.utf8 {
            let imm16 = UInt16(character)
            let lower = Int(imm16 & 0x00ff)
            let upper = Int((imm16 & 0xff00) >> 8)
            children += [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI,    parameters:[src, ParameterNumber(lower)]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI,   parameters:[src, ParameterNumber(upper)]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kSTORE, parameters: [src, dst, ParameterNumber(0)]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI,  parameters: [dst, dst, ParameterNumber(1)])
            ]
        }
        return Seq(sourceAnchor: sourceAnchor, children: children)
    }
    
    func memcpy(_ sourceAnchor: SourceAnchor?,
                _ dst_: TackInstruction.RegisterPointer,
                _ src_: TackInstruction.RegisterPointer,
                _ numberOfWords: Int) -> AbstractSyntaxTreeNode? {
        // TODO: Use the offset parameter of the STORE instruction to improve MEMCPY performance.
        let originalDst = corresponding(.w(dst_))
        let originalSrc = corresponding(.w(src_))
        switch numberOfWords {
        case 0:
            return Seq(sourceAnchor: sourceAnchor)
            
        case 1:
            let temp = ParameterIdentifier(nextRegister())
            var children: [AbstractSyntaxTreeNode] = []
            for _ in 0..<numberOfWords {
                children += [
                    InstructionNode(sourceAnchor: sourceAnchor, instruction: kLOAD, parameters: [temp, originalSrc, ParameterNumber(0)]),
                    InstructionNode(sourceAnchor: sourceAnchor, instruction: kSTORE, parameters: [temp, originalDst, ParameterNumber(0)])
                ]
            }
            return Seq(children: children)
            
        default:
            // TODO: If the number of words to memcpy is large then generate code for a loop instead of this.
            let dst = ParameterIdentifier(nextRegister())
            let src = ParameterIdentifier(nextRegister())
            let temp = ParameterIdentifier(nextRegister())
            var children: [AbstractSyntaxTreeNode] = [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: [dst, originalDst, ParameterNumber(0)]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: [src, originalSrc, ParameterNumber(0)])
            ]
            for _ in 0..<numberOfWords {
                children += [
                    InstructionNode(sourceAnchor: sourceAnchor, instruction: kLOAD, parameters: [temp, src, ParameterNumber(0)]),
                    InstructionNode(sourceAnchor: sourceAnchor, instruction: kSTORE, parameters: [temp, dst, ParameterNumber(0)]),
                    InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI,  parameters: [dst, dst, ParameterNumber(1)]),
                    InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI,  parameters: [src, src, ParameterNumber(1)])
                ]
            }
            return Seq(sourceAnchor: sourceAnchor, children: children)
        }
    }
    
    func alloca(_ sourceAnchor: SourceAnchor?,
                _ dst_: TackInstruction.RegisterPointer,
                _ size: Int) -> AbstractSyntaxTreeNode? {
        return Seq(sourceAnchor: sourceAnchor, children: [
            subi16(sourceAnchor, .sp, .sp, size)!,
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters:[
                corresponding(.w(dst_)),
                ParameterIdentifier("sp"),
                ParameterNumber(0)
            ])
        ])
    }
    
    func free(_ sourceAnchor: SourceAnchor?, _ size: Int) -> AbstractSyntaxTreeNode? {
        return addi16(sourceAnchor, .sp, .sp, size)
    }
    
    fileprivate func opWithImm16(_ sourceAnchor: SourceAnchor?,
                                 _ rrr: String,
                                 _ rri: String,
                                 _ dst_: TackInstruction.Register16,
                                 _ left_: TackInstruction.Register16,
                                 _ imm: Int) -> AbstractSyntaxTreeNode? {
        if imm > 15 || imm < -16 {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let left = corresponding(.w(left_))
            let right = nextRegister()
            let dst = corresponding(.w(dst_))
            
            return Seq(sourceAnchor: sourceAnchor, children: [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters:[
                    ParameterIdentifier(right),
                    ParameterNumber(Int(imm16 & 0x00ff))
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters:[
                    ParameterIdentifier(right),
                    ParameterNumber(Int((imm16 & 0xff00) >> 8))
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: rrr, parameters:[
                    dst,
                    left,
                    ParameterIdentifier(right)
                ])
            ])
        }
        else {
            let left = corresponding(.w(left_))
            let dst = corresponding(.w(dst_))
            return InstructionNode(sourceAnchor: sourceAnchor, instruction: rri, parameters: [
                dst,
                left,
                ParameterNumber(imm)
            ])
        }
    }
    
    func andi16(_ sourceAnchor: SourceAnchor?,
                _ dst_: TackInstruction.Register16,
                _ left_: TackInstruction.Register16,
                _ imm: Int) -> AbstractSyntaxTreeNode? {
        return opWithImm16(sourceAnchor, kAND, kANDI, dst_, left_, imm)
    }
    
    func addi16(_ sourceAnchor: SourceAnchor?,
                _ dst_: TackInstruction.Register16,
                _ left_: TackInstruction.Register16,
                _ imm: Int) -> AbstractSyntaxTreeNode? {
        return opWithImm16(sourceAnchor, kADD, kADDI, dst_, left_, imm)
    }
    
    func subi16(_ sourceAnchor: SourceAnchor?,
                _ dst_: TackInstruction.Register16,
                _ left_: TackInstruction.Register16,
                _ imm: Int) -> AbstractSyntaxTreeNode? {
        return opWithImm16(sourceAnchor, kSUB, kSUBI, dst_, left_, imm)
    }
    
    func muli16(_ sourceAnchor: SourceAnchor?,
                _ dst_: TackInstruction.Register16,
                _ left_: TackInstruction.Register16,
                _ imm: Int) -> AbstractSyntaxTreeNode? {
        
        if imm == 0 {
            _ = corresponding(.w(left_))
            let dst = corresponding(.w(dst_))
            
            return InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters:[
                dst,
                ParameterNumber(0)
            ])
        }
        else if imm == 1 {
            let src = corresponding(.w(left_))
            let dst = corresponding(.w(dst_))
            
            return Seq(sourceAnchor: sourceAnchor, children: [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters:[
                    dst,
                    src,
                    ParameterNumber(0)
                ])
            ])
        }
        else if imm == -1 {
            let src = corresponding(.w(left_))
            let intermediate = ParameterIdentifier(nextRegister())
            let dst = corresponding(.w(dst_))
            
            return Seq(sourceAnchor: sourceAnchor, children: [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kNOT, parameters:[
                    intermediate,
                    src
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters:[
                    dst,
                    intermediate,
                    ParameterNumber(1)
                ])
            ])
        }
        
        return muli16_pow2(sourceAnchor, dst_, left_, imm)
    }
    
    fileprivate func muli16_pow2(_ sourceAnchor: SourceAnchor?,
                                 _ dst_: TackInstruction.Register16,
                                 _ left_: TackInstruction.Register16,
                                 _ imm: Int) -> AbstractSyntaxTreeNode? {
        // Adding a number to itself is a quick way to multiply by two.
        // Decompose the multiplication into the sum of powers of two to take
        // advantage of this fact.
        assert(registerMap[.w(dst_)] == nil)
        
        var children: [InstructionNode] = []
        let mustNegateAtEnd = imm < 0
        var multiplicand = abs(imm)
        assert(multiplicand > 1)
        let multiplier = corresponding(.w(left_))
        var resultStack: [ParameterIdentifier] = []
        
        while multiplicand > 1 {
            let exponent = Int(log2(Float(multiplicand)))
            multiplicand -= (pow(2, exponent) as NSDecimalNumber).intValue
            resultStack.append(ParameterIdentifier(nextRegister()))
            
            children += [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kADD, parameters:[
                    resultStack[resultStack.count - 1],
                    multiplier,
                    multiplier,
                ])
            ]
            for _ in 1..<exponent {
                children += [
                    InstructionNode(sourceAnchor: sourceAnchor, instruction: kADD, parameters:[
                        resultStack[resultStack.count - 1],
                        resultStack[resultStack.count - 1],
                        resultStack[resultStack.count - 1],
                    ])
                ]
            }
        }
        
        var sum: ParameterIdentifier
        
        if resultStack.count < 2 {
            sum = resultStack.last!
        }
        else {
            sum = ParameterIdentifier(nextRegister())
            children += [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kADD, parameters:[
                    sum,
                    resultStack[0],
                    resultStack[1],
                ])
            ]
            for component in resultStack[2..<resultStack.count] {
                children += [
                    InstructionNode(sourceAnchor: sourceAnchor, instruction: kADD, parameters:[
                        sum,
                        sum,
                        component,
                    ])
                ]
            }
        }
        
        if multiplicand == 1 {
            children += [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kADD, parameters:[
                    sum,
                    sum,
                    multiplier
                ])
            ]
        }
        
        if mustNegateAtEnd {
            let t1 = ParameterIdentifier(nextRegister())
            let t2 = ParameterIdentifier(nextRegister())
            children += [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kNOT, parameters:[
                    t1,
                    sum
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters:[
                    t2,
                    t1,
                    ParameterNumber(1)
                ])
            ]
            sum = t2
        }
        
        registerMap[.w(dst_)] = sum.value
        
        return Seq(children: children)
    }
    
    func li16(_ sourceAnchor: SourceAnchor?,
              _ dst_: TackInstruction.Register16,
              _ imm: Int) -> AbstractSyntaxTreeNode? {
        if imm >= Int8.min && imm <= Int8.max {
            let dst = corresponding(.w(dst_))
            return InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [
                dst,
                ParameterNumber(imm)
            ])
        }
        else {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let dst = corresponding(.w(dst_))
            let lower = Int(imm16 & 0x00ff)
            let upper = Int((imm16 & 0xff00) >> 8)
            
            return Seq(sourceAnchor: sourceAnchor, children: [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters:[
                    dst,
                    ParameterNumber(lower)
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters:[
                    dst,
                    ParameterNumber(upper)
                ])
            ])
        }
    }
    
    func liu16(_ sourceAnchor: SourceAnchor?,
               _ dst_: TackInstruction.Register16,
               _ imm: Int) -> AbstractSyntaxTreeNode? {
        if imm > 127 {
            let imm16 = UInt16(imm)
            let dst = corresponding(.w(dst_))
            let lower = Int(imm16 & 0x00ff)
            let upper = Int((imm16 & 0xff00) >> 8)
            
            return Seq(sourceAnchor: sourceAnchor, children: [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters:[
                    dst,
                    ParameterNumber(lower)
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters:[
                    dst,
                    ParameterNumber(upper)
                ])
            ])
        }
        else {
            let dst = corresponding(.w(dst_))
            return InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [
                dst,
                ParameterNumber(imm)
            ])
        }
    }
    
    func and16(_ sourceAnchor: SourceAnchor?,
               _ c_: TackInstruction.Register16,
               _ a_: TackInstruction.Register16,
               _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        return InstructionNode(sourceAnchor: sourceAnchor, instruction: kAND, parameters: [
            c, a, b
        ])
    }
    
    func or16(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register16,
              _ a_: TackInstruction.Register16,
              _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        return InstructionNode(sourceAnchor: sourceAnchor, instruction: kOR, parameters: [
            c, a, b
        ])
    }
    
    func xor16(_ sourceAnchor: SourceAnchor?,
               _ c_: TackInstruction.Register16,
               _ a_: TackInstruction.Register16,
               _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        return InstructionNode(sourceAnchor: sourceAnchor, instruction: kXOR, parameters: [
            c, a, b
        ])
    }
    
    func neg16(_ sourceAnchor: SourceAnchor?,
               _ dst_: TackInstruction.Register16,
               _ src_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let src = corresponding(.w(src_))
        let dst = corresponding(.w(dst_))
        return InstructionNode(sourceAnchor: sourceAnchor, instruction: kNOT, parameters: [
            dst, src
        ])
    }
    
    func add16(_ sourceAnchor: SourceAnchor?,
               _ c_: TackInstruction.Register16,
               _ a_: TackInstruction.Register16,
               _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        return InstructionNode(sourceAnchor: sourceAnchor, instruction: kADD, parameters: [
            c, a, b
        ])
    }
    
    func sub16(_ sourceAnchor: SourceAnchor?,
               _ c_: TackInstruction.Register16,
               _ a_: TackInstruction.Register16,
               _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        return InstructionNode(sourceAnchor: sourceAnchor, instruction: kSUB, parameters: [
            c, a, b
        ])
    }
    
    fileprivate let labelMaker = LabelMaker(prefix: ".LL")
    
    func mul16(_ sourceAnchor: SourceAnchor?,
               _ c_: TackInstruction.Register16,
               _ a_: TackInstruction.Register16,
               _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let right = corresponding(.w(b_))
        let left = corresponding(.w(a_))
        let counter = ParameterIdentifier(nextRegister())
        let result = corresponding(.w(c_))
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [
                result,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: [
                counter,
                left,
                ParameterNumber(0)
            ]),
            LabelDeclaration(identifier: head),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMPI, parameters: [
                counter,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBEQ, parameters: [
                ParameterIdentifier(tail)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADD, parameters: [
                result,
                result,
                right
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kSUBI, parameters: [
                counter,
                counter,
                ParameterNumber(1)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kJMP, parameters: [
                ParameterIdentifier(head)
            ]),
            LabelDeclaration(identifier: tail)
        ])
    }
    
    func div16(_ sourceAnchor: SourceAnchor?,
               _ c_: TackInstruction.Register16,
               _ a_: TackInstruction.Register16,
               _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let right = corresponding(.w(b_))
        let left = corresponding(.w(a_))
        let tempLeft = ParameterIdentifier(nextRegister())
        let result = corresponding(.w(c_))
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [
                result,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMPI, parameters: [
                right,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBEQ, parameters: [
                ParameterIdentifier(tail)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: [
                tempLeft,
                left,
                ParameterNumber(0)
            ]),
            LabelDeclaration(identifier: head),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [
                tempLeft,
                right
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBLTU, parameters: [
                ParameterIdentifier(tail)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kSUB, parameters: [
                tempLeft,
                tempLeft,
                right
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: [
                result,
                result,
                ParameterNumber(1)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kJMP, parameters: [
                ParameterIdentifier(head)
            ]),
            LabelDeclaration(identifier: tail)
        ])
    }
    
    func mod16(_ sourceAnchor: SourceAnchor?,
               _ c_: TackInstruction.Register16,
               _ a_: TackInstruction.Register16,
               _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let right = corresponding(.w(b_))
        let left = corresponding(.w(a_))
        let tempLeft = corresponding(.w(c_))
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: [
                tempLeft,
                left,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMPI, parameters: [
                right,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBEQ, parameters: [
                ParameterIdentifier(tail)
            ]),
            LabelDeclaration(identifier: head),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [
                tempLeft,
                right
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBLTU, parameters: [
                ParameterIdentifier(tail)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kSUB, parameters: [
                tempLeft,
                tempLeft,
                right
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kJMP, parameters: [
                ParameterIdentifier(head)
            ]),
            LabelDeclaration(identifier: tail)
        ])
    }
    
    func lsl16(_ sourceAnchor: SourceAnchor?,
               _ c_: TackInstruction.Register16,
               _ a_: TackInstruction.Register16,
               _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let N = 16
        let b = corresponding(.w(c_)) // TODO: Terrible naming conventions for the local vars here
        let a = corresponding(.w(a_))
        let n = corresponding(.w(b_))
        let temp = ParameterIdentifier(nextRegister())
        let mask1 = ParameterIdentifier(nextRegister())
        let mask2 = ParameterIdentifier(nextRegister())
        let i = ParameterIdentifier(nextRegister())
        let head_shift = ParameterIdentifier(labelMaker.next())
        let tail_shift = ParameterIdentifier(labelMaker.next())
        let head_body = ParameterIdentifier(labelMaker.next())
        let skip = ParameterIdentifier(labelMaker.next())
        let tail_body = ParameterIdentifier(labelMaker.next())
        
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(instruction: kLI, parameters: [b, ParameterNumber(0)]),
            InstructionNode(instruction: kLI, parameters: [mask1, ParameterNumber(1)]),
            InstructionNode(instruction: kLI, parameters: [mask2, ParameterNumber(1)]),
            InstructionNode(instruction: kADDI, parameters: [temp, n, ParameterNumber(0)]),
            LabelDeclaration(head_shift),
            InstructionNode(instruction: kCMPI, parameters: [temp, ParameterNumber(0)]),
            InstructionNode(instruction: kBEQ, parameter: tail_shift),
            InstructionNode(instruction: kADD, parameters: [mask2, mask2, mask2]),
            InstructionNode(instruction: kSUBI, parameters: [temp, temp, ParameterNumber(1)]),
            InstructionNode(instruction: kJMP, parameter: head_shift),
            LabelDeclaration(tail_shift),
            InstructionNode(instruction: kLI, parameters: [i, ParameterNumber(0)]),
            LabelDeclaration(head_body),
            InstructionNode(instruction: kLI, parameters: [temp, ParameterNumber(N)]),
            InstructionNode(instruction: kSUB, parameters: [temp, temp, n]),
            InstructionNode(instruction: kCMP, parameters: [temp, i]),
            InstructionNode(instruction: kBLT, parameter: tail_body),
            InstructionNode(instruction: kAND, parameters: [temp, a, mask1]),
            InstructionNode(instruction: kCMPI, parameters: [temp, ParameterNumber(0)]),
            InstructionNode(instruction: kBEQ, parameter: skip),
            InstructionNode(instruction: kOR, parameters: [b, b, mask2]),
            LabelDeclaration(skip),
            InstructionNode(instruction: kADD, parameters: [mask1, mask1, mask1]),
            InstructionNode(instruction: kADD, parameters: [mask2, mask2, mask2]),
            InstructionNode(instruction: kADDI, parameters: [i, i, ParameterNumber(1)]),
            InstructionNode(instruction: kJMP, parameter: head_body),
            LabelDeclaration(tail_body)
        ])
    }
    
    func lsr16(_ sourceAnchor: SourceAnchor?,
               _ c_: TackInstruction.Register16,
               _ a_: TackInstruction.Register16,
               _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let N = 16
        let b = corresponding(.w(c_)) // TODO: Terrible naming conventions for the local vars here
        let a = corresponding(.w(a_))
        let n = corresponding(.w(b_))
        let temp = ParameterIdentifier(nextRegister())
        let mask1 = ParameterIdentifier(nextRegister())
        let mask2 = ParameterIdentifier(nextRegister())
        let i = ParameterIdentifier(nextRegister())
        let head_shift = ParameterIdentifier(labelMaker.next())
        let tail_shift = ParameterIdentifier(labelMaker.next())
        let head_body = ParameterIdentifier(labelMaker.next())
        let skip = ParameterIdentifier(labelMaker.next())
        let tail_body = ParameterIdentifier(labelMaker.next())
        
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(instruction: kLI, parameters: [b, ParameterNumber(0)]),
            InstructionNode(instruction: kLI, parameters: [mask1, ParameterNumber(1)]),
            InstructionNode(instruction: kLI, parameters: [mask2, ParameterNumber(1)]),
            InstructionNode(instruction: kADDI, parameters: [temp, n, ParameterNumber(0)]),
            LabelDeclaration(head_shift),
            InstructionNode(instruction: kCMPI, parameters: [temp, ParameterNumber(0)]),
            InstructionNode(instruction: kBEQ, parameter: tail_shift),
            InstructionNode(instruction: kADD, parameters: [mask2, mask2, mask2]),
            InstructionNode(instruction: kSUBI, parameters: [temp, temp, ParameterNumber(1)]),
            InstructionNode(instruction: kJMP, parameter: head_shift),
            LabelDeclaration(tail_shift),
            InstructionNode(instruction: kLI, parameters: [i, ParameterNumber(0)]),
            LabelDeclaration(head_body),
            InstructionNode(instruction: kLI, parameters: [temp, ParameterNumber(N)]),
            InstructionNode(instruction: kSUB, parameters: [temp, temp, n]),
            InstructionNode(instruction: kCMP, parameters: [temp, i]),
            InstructionNode(instruction: kBLT, parameter: tail_body),
            InstructionNode(instruction: kAND, parameters: [temp, a, mask2]),
            InstructionNode(instruction: kCMPI, parameters: [temp, ParameterNumber(0)]),
            InstructionNode(instruction: kBEQ, parameter: skip),
            InstructionNode(instruction: kOR, parameters: [b, b, mask1]),
            LabelDeclaration(skip),
            InstructionNode(instruction: kADD, parameters: [mask1, mask1, mask1]),
            InstructionNode(instruction: kADD, parameters: [mask2, mask2, mask2]),
            InstructionNode(instruction: kADDI, parameters: [i, i, ParameterNumber(1)]),
            InstructionNode(instruction: kJMP, parameter: head_body),
            LabelDeclaration(tail_body)
        ])
    }
    
    func eq16(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register16,
              _ a_: TackInstruction.Register16,
              _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBEQ, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func ne16(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register16,
              _ a_: TackInstruction.Register16,
              _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBNE, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func lt16(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register16,
              _ a_: TackInstruction.Register16,
              _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBLT, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func ge16(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register16,
              _ a_: TackInstruction.Register16,
              _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(instruction: kBLT, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func le16(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register16,
              _ a_: TackInstruction.Register16,
              _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(instruction: kBGT, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func gt16(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register16,
              _ a_: TackInstruction.Register16,
              _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBGT, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func ltu16(_ sourceAnchor: SourceAnchor?,
               _ c_: TackInstruction.Register16,
               _ a_: TackInstruction.Register16,
               _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBLTU, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func geu16(_ sourceAnchor: SourceAnchor?,
               _ c_: TackInstruction.Register16,
               _ a_: TackInstruction.Register16,
               _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(instruction: kBLTU, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func leu16(_ sourceAnchor: SourceAnchor?,
               _ c_: TackInstruction.Register16,
               _ a_: TackInstruction.Register16,
               _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(instruction: kBGTU, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func gtu16(_ sourceAnchor: SourceAnchor?,
               _ c_: TackInstruction.Register16,
               _ a_: TackInstruction.Register16,
               _ b_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBGTU, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func li8(_ sourceAnchor: SourceAnchor?,
             _ dst_: TackInstruction.Register8,
             _ imm: Int) -> AbstractSyntaxTreeNode? {
        // The hardware always sign-extends this immediate value.
        assert(imm >= -128 && imm < 128)
        let dst = corresponding(.b(dst_))
        return InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [
            dst,
            ParameterNumber(imm)
        ])
    }
    
    func liu8(_ sourceAnchor: SourceAnchor?,
              _ dst_: TackInstruction.Register8,
              _ imm: Int) -> AbstractSyntaxTreeNode? {
        // The hardware always sign-extends this immediate value. We may need
        // an extra instruction to circumvent this behavior.
        assert(imm >= 0 && imm < 256)
        let dst = corresponding(.b(dst_))
        if imm > 127 {
            return Seq(sourceAnchor: sourceAnchor, children: [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [
                    dst,
                    ParameterNumber(imm)
                ]),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters: [
                    dst,
                    ParameterNumber(0)
                ])
            ])
        }
        else {
            return InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [
                dst,
                ParameterNumber(imm)
            ])
        }
    }
    
    func and8(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register8,
              _ a_: TackInstruction.Register8,
              _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.b(c_))
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kAND, parameters: [c, a, b]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters: [
                c,
                ParameterNumber(0)
            ])
        ])
    }
    
    func or8(_ sourceAnchor: SourceAnchor?,
             _ c_: TackInstruction.Register8,
             _ a_: TackInstruction.Register8,
             _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.b(c_))
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kOR, parameters: [c, a, b]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters: [
                c,
                ParameterNumber(0)
            ])
        ])
    }
    
    func xor8(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register8,
              _ a_: TackInstruction.Register8,
              _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.b(c_))
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kXOR, parameters: [c, a, b]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters: [
                c,
                ParameterNumber(0)
            ])
        ])
    }
    
    func neg8(_ sourceAnchor: SourceAnchor?,
              _ dst_: TackInstruction.Register8,
              _ src_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let src = corresponding(.b(src_))
        let dst = corresponding(.b(dst_))
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kNOT, parameters: [dst, src]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters: [
                dst,
                ParameterNumber(0)
            ])
        ])
    }
    
    func signExtend8(_ c: Parameter) -> Seq {
        let temp = ParameterIdentifier(nextRegister())
        return Seq(children: [
            InstructionNode(instruction: kLI, parameters: [
                temp,
                ParameterNumber(0x80)
            ]),
            InstructionNode(instruction: kLUI, parameters: [
                temp,
                ParameterNumber(0x00)
            ]),
            InstructionNode(instruction: kLUI, parameters: [
                c,
                ParameterNumber(0)
            ]),
            InstructionNode(instruction: kXOR, parameters: [
                c,
                c,
                temp
            ]),
            InstructionNode(instruction: kSUB, parameters: [
                c,
                c,
                temp
            ])
        ])
    }
    
    func add8(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register8,
              _ a_: TackInstruction.Register8,
              _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.b(c_))
        
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADD, parameters: [c, a, b]),
            signExtend8(c)
        ])
    }
    
    func sub8(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register8,
              _ a_: TackInstruction.Register8,
              _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.b(c_))
        
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kSUB, parameters: [c, a, b]),
            signExtend8(c)
        ])
    }
    
    func mul8(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register8,
              _ a_: TackInstruction.Register8,
              _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        // TODO: Consolidate implementation with the very similar mul16()
        let right = corresponding(.b(b_))
        let left = corresponding(.b(a_))
        let counter = ParameterIdentifier(nextRegister())
        let result = corresponding(.b(c_))
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [
                result,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: [
                counter,
                left,
                ParameterNumber(0)
            ]),
            LabelDeclaration(identifier: head),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMPI, parameters: [
                counter,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBEQ, parameters: [
                ParameterIdentifier(tail)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADD, parameters: [
                result,
                result,
                right
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kSUBI, parameters: [
                counter,
                counter,
                ParameterNumber(1)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kJMP, parameters: [
                ParameterIdentifier(head)
            ]),
            LabelDeclaration(identifier: tail),
            signExtend8(corresponding(.b(c_)))
        ])
    }
    
    func div8(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register8,
              _ a_: TackInstruction.Register8,
              _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        // TODO: Consolidate implementation with the very similar div16()
        let right = corresponding(.b(b_))
        let left = corresponding(.b(a_))
        let tempLeft = ParameterIdentifier(nextRegister())
        let result = corresponding(.b(c_))
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [
                result,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMPI, parameters: [
                right,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBEQ, parameters: [
                ParameterIdentifier(tail)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: [
                tempLeft,
                left,
                ParameterNumber(0)
            ]),
            LabelDeclaration(identifier: head),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [
                tempLeft,
                right
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBLTU, parameters: [
                ParameterIdentifier(tail)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kSUB, parameters: [
                tempLeft,
                tempLeft,
                right
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: [
                result,
                result,
                ParameterNumber(1)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kJMP, parameters: [
                ParameterIdentifier(head)
            ]),
            LabelDeclaration(identifier: tail),
            signExtend8(corresponding(.b(c_)))
        ])
    }
    
    func mod8(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register8,
              _ a_: TackInstruction.Register8,
              _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        // TODO: Consolidate implementation with the very similar mod16()
        let right = corresponding(.b(b_))
        let left = corresponding(.b(a_))
        let tempLeft = corresponding(.b(c_))
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: [
                tempLeft,
                left,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMPI, parameters: [
                right,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBEQ, parameters: [
                ParameterIdentifier(tail)
            ]),
            LabelDeclaration(identifier: head),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [
                tempLeft,
                right
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBLTU, parameters: [
                ParameterIdentifier(tail)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kSUB, parameters: [
                tempLeft,
                tempLeft,
                right
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kJMP, parameters: [
                ParameterIdentifier(head)
            ]),
            LabelDeclaration(identifier: tail),
            signExtend8(corresponding(.b(c_)))
        ])
    }
    
    func lsl8(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register8,
              _ a_: TackInstruction.Register8,
              _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        // TODO: Consolidate implementation with the very similar lsl16()
        let N = 16
        let b = corresponding(.b(c_)) // TODO: Terrible naming conventions for the local vars here
        let a = corresponding(.b(a_))
        let n = corresponding(.b(b_))
        let temp = ParameterIdentifier(nextRegister())
        let mask1 = ParameterIdentifier(nextRegister())
        let mask2 = ParameterIdentifier(nextRegister())
        let i = ParameterIdentifier(nextRegister())
        let head_shift = ParameterIdentifier(labelMaker.next())
        let tail_shift = ParameterIdentifier(labelMaker.next())
        let head_body = ParameterIdentifier(labelMaker.next())
        let skip = ParameterIdentifier(labelMaker.next())
        let tail_body = ParameterIdentifier(labelMaker.next())
        
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(instruction: kLI, parameters: [b, ParameterNumber(0)]),
            InstructionNode(instruction: kLI, parameters: [mask1, ParameterNumber(1)]),
            InstructionNode(instruction: kLI, parameters: [mask2, ParameterNumber(1)]),
            InstructionNode(instruction: kADDI, parameters: [temp, n, ParameterNumber(0)]),
            LabelDeclaration(head_shift),
            InstructionNode(instruction: kCMPI, parameters: [temp, ParameterNumber(0)]),
            InstructionNode(instruction: kBEQ, parameter: tail_shift),
            InstructionNode(instruction: kADD, parameters: [mask2, mask2, mask2]),
            InstructionNode(instruction: kSUBI, parameters: [temp, temp, ParameterNumber(1)]),
            InstructionNode(instruction: kJMP, parameter: head_shift),
            LabelDeclaration(tail_shift),
            InstructionNode(instruction: kLI, parameters: [i, ParameterNumber(0)]),
            LabelDeclaration(head_body),
            InstructionNode(instruction: kLI, parameters: [temp, ParameterNumber(N)]),
            InstructionNode(instruction: kSUB, parameters: [temp, temp, n]),
            InstructionNode(instruction: kCMP, parameters: [temp, i]),
            InstructionNode(instruction: kBLT, parameter: tail_body),
            InstructionNode(instruction: kAND, parameters: [temp, a, mask1]),
            InstructionNode(instruction: kCMPI, parameters: [temp, ParameterNumber(0)]),
            InstructionNode(instruction: kBEQ, parameter: skip),
            InstructionNode(instruction: kOR, parameters: [b, b, mask2]),
            LabelDeclaration(skip),
            InstructionNode(instruction: kADD, parameters: [mask1, mask1, mask1]),
            InstructionNode(instruction: kADD, parameters: [mask2, mask2, mask2]),
            InstructionNode(instruction: kADDI, parameters: [i, i, ParameterNumber(1)]),
            InstructionNode(instruction: kJMP, parameter: head_body),
            LabelDeclaration(tail_body),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters: [
                corresponding(.b(c_)),
                ParameterNumber(0)
            ])
        ])
    }
    
    func lsr8(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.Register8,
              _ a_: TackInstruction.Register8,
              _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        // TODO: Consolidate implementation with the very similar lsr16()
        let N = 16
        let b = corresponding(.b(c_)) // TODO: Terrible naming conventions for the local vars here
        let a = corresponding(.b(a_))
        let n = corresponding(.b(b_))
        let temp = ParameterIdentifier(nextRegister())
        let mask1 = ParameterIdentifier(nextRegister())
        let mask2 = ParameterIdentifier(nextRegister())
        let i = ParameterIdentifier(nextRegister())
        let head_shift = ParameterIdentifier(labelMaker.next())
        let tail_shift = ParameterIdentifier(labelMaker.next())
        let head_body = ParameterIdentifier(labelMaker.next())
        let skip = ParameterIdentifier(labelMaker.next())
        let tail_body = ParameterIdentifier(labelMaker.next())
        
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(instruction: kLI, parameters: [b, ParameterNumber(0)]),
            InstructionNode(instruction: kLI, parameters: [mask1, ParameterNumber(1)]),
            InstructionNode(instruction: kLI, parameters: [mask2, ParameterNumber(1)]),
            InstructionNode(instruction: kADDI, parameters: [temp, n, ParameterNumber(0)]),
            LabelDeclaration(head_shift),
            InstructionNode(instruction: kCMPI, parameters: [temp, ParameterNumber(0)]),
            InstructionNode(instruction: kBEQ, parameter: tail_shift),
            InstructionNode(instruction: kADD, parameters: [mask2, mask2, mask2]),
            InstructionNode(instruction: kSUBI, parameters: [temp, temp, ParameterNumber(1)]),
            InstructionNode(instruction: kJMP, parameter: head_shift),
            LabelDeclaration(tail_shift),
            InstructionNode(instruction: kLI, parameters: [i, ParameterNumber(0)]),
            LabelDeclaration(head_body),
            InstructionNode(instruction: kLI, parameters: [temp, ParameterNumber(N)]),
            InstructionNode(instruction: kSUB, parameters: [temp, temp, n]),
            InstructionNode(instruction: kCMP, parameters: [temp, i]),
            InstructionNode(instruction: kBLT, parameter: tail_body),
            InstructionNode(instruction: kAND, parameters: [temp, a, mask2]),
            InstructionNode(instruction: kCMPI, parameters: [temp, ParameterNumber(0)]),
            InstructionNode(instruction: kBEQ, parameter: skip),
            InstructionNode(instruction: kOR, parameters: [b, b, mask1]),
            LabelDeclaration(skip),
            InstructionNode(instruction: kADD, parameters: [mask1, mask1, mask1]),
            InstructionNode(instruction: kADD, parameters: [mask2, mask2, mask2]),
            InstructionNode(instruction: kADDI, parameters: [i, i, ParameterNumber(1)]),
            InstructionNode(instruction: kJMP, parameter: head_body),
            LabelDeclaration(tail_body),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters: [
                corresponding(.b(c_)),
                ParameterNumber(0)
            ])
        ])
    }
    
    func eq8(_ sourceAnchor: SourceAnchor?,
             _ c_: TackInstruction.RegisterBoolean,
             _ a_: TackInstruction.Register8,
             _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBEQ, parameter: ll0),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func ne8(_ sourceAnchor: SourceAnchor?,
             _ c_: TackInstruction.RegisterBoolean,
             _ a_: TackInstruction.Register8,
             _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBNE, parameter: ll0),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func lt8(_ sourceAnchor: SourceAnchor?,
             _ c_: TackInstruction.RegisterBoolean,
             _ a_: TackInstruction.Register8,
             _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBLT, parameter: ll0),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func ge8(_ sourceAnchor: SourceAnchor?,
             _ c_: TackInstruction.RegisterBoolean,
             _ a_: TackInstruction.Register8,
             _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBLT, parameter: ll0),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func le8(_ sourceAnchor: SourceAnchor?,
             _ c_: TackInstruction.RegisterBoolean,
             _ a_: TackInstruction.Register8,
             _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBGT, parameter: ll0),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func gt8(_ sourceAnchor: SourceAnchor?,
             _ c_: TackInstruction.RegisterBoolean,
             _ a_: TackInstruction.Register8,
             _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBGT, parameter: ll0),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func ltu8(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.RegisterBoolean,
              _ a_: TackInstruction.Register8,
              _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBLTU, parameter: ll0),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func geu8(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.RegisterBoolean,
              _ a_: TackInstruction.Register8,
              _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBLTU, parameter: ll0),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func leu8(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.RegisterBoolean,
              _ a_: TackInstruction.Register8,
              _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBGTU, parameter: ll0),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func gtu8(_ sourceAnchor: SourceAnchor?,
              _ c_: TackInstruction.RegisterBoolean,
              _ a_: TackInstruction.Register8,
              _ b_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.w(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kBGTU, parameter: ll0),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func movsbw(_ sourceAnchor: SourceAnchor?,
                _ dst_: TackInstruction.Register8,
                _ src_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        // Take lower eight-bits of the value in the source register, sign-
        // extend this to sixteen bits, and write the result to the destination
        // register.
        let src = corresponding(.w(src_))
        let dst = corresponding(.b(dst_))
        let temp = ParameterIdentifier(nextRegister())
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: [
                dst,
                src,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [
                temp,
                ParameterNumber(0x80)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters: [
                temp,
                ParameterNumber(0x00)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters: [
                dst,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kXOR, parameters: [
                dst,
                dst,
                temp
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kSUB, parameters: [
                dst,
                dst,
                temp
            ])
        ])
    }
    
    func movswb(_ sourceAnchor: SourceAnchor?,
                _ dst_: TackInstruction.Register16,
                _ src_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        // Take lower eight-bits of the value in the source register, sign-
        // extend this to sixteen bits, and write the result to the destination
        // register.
        let src = corresponding(.b(src_))
        let dst = corresponding(.w(dst_))
        let temp = ParameterIdentifier(nextRegister())
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: [
                dst,
                src,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLI, parameters: [
                temp,
                ParameterNumber(0x80)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters: [
                temp,
                ParameterNumber(0x00)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters: [
                dst,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kXOR, parameters: [
                dst,
                dst,
                temp
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kSUB, parameters: [
                dst,
                dst,
                temp
            ])
        ])
    }
    
    func movzwb(_ sourceAnchor: SourceAnchor?,
                _ dst_: TackInstruction.Register16,
                _ src_: TackInstruction.Register8) -> AbstractSyntaxTreeNode? {
        // Move an eight-bit register to a sixteen-bit register, zero-extending
        // to fill the upper bits.
        let src = corresponding(.b(src_))
        let dst = corresponding(.w(dst_))
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: [
                dst,
                src,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters: [
                dst,
                ParameterNumber(0x00)
            ])
        ])
    }
    
    func movzbw(_ sourceAnchor: SourceAnchor?,
                _ dst_: TackInstruction.Register8,
                _ src_: TackInstruction.Register16) -> AbstractSyntaxTreeNode? {
        // Move a sixteen-bit register to a eight-bit register, zero-extending
        // to fill the upper bits.
        let src = corresponding(.w(src_))
        let dst = corresponding(.b(dst_))
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: [
                dst,
                src,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kLUI, parameters: [
                dst,
                ParameterNumber(0x00)
            ])
        ])
    }
    
    func inlineAssembly(_ assemblyCode: String) throws -> AbstractSyntaxTreeNode? {
        // Lexer pass
        let lexer = AssemblerLexer(assemblyCode)
        lexer.scanTokens()
        if let error = lexer.errors.first {
            throw error
        }
        
        // Compile to an abstract syntax tree
        let parser = AssemblerParser(tokens: lexer.tokens, lineMapper: lexer.lineMapper)
        parser.parse()
        if let error = parser.errors.first {
            throw error
        }
        guard let syntaxTree = parser.syntaxTree else {
            return nil
        }
        return Seq(children: syntaxTree.children)
    }
    
    func syscall(_ sourceAnchor: SourceAnchor?,
                 _ n_: TackInstruction.Register16,
                 _ ptr_: TackInstruction.RegisterPointer) -> AbstractSyntaxTreeNode? {
        return Seq(sourceAnchor: sourceAnchor, children: [
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kNOP),
            InstructionNode(sourceAnchor: sourceAnchor, instruction: kHLT)
        ])
    }
}
