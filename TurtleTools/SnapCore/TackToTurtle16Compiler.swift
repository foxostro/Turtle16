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
    
    fileprivate var registerMap: [String:String] = [:]
    
    fileprivate func corresponding(_ ident: String) -> String {
        if ident == "sp" {
            return ident
        }
        else if ident == "fp" {
            return ident
        }
        else if ident == "ra" {
            return ident
        }
        else {
            assert(ident.starts(with: "vr"))
            if let result = registerMap[ident] {
                return result
            } else {
                let result = nextRegister()
                registerMap[ident] = result
                return result
            }
        }
    }
    
    fileprivate func corresponding(param: Parameter) -> Parameter {
        guard let ident = param as? ParameterIdentifier else {
            return param
        }
        let rewritten = corresponding(ident.value)
        return ParameterIdentifier(sourceAnchor: param.sourceAnchor, value: rewritten)
    }
    
    fileprivate func corresponding(parameters: [Parameter]) -> [Parameter] {
        return parameters.reversed().map({ corresponding(param: $0) }).reversed()
    }
    
    public override func compile(instruction node: InstructionNode) throws -> AbstractSyntaxTreeNode? {
        switch node.instruction {
        case Tack.kCALL: return call(node)
        case Tack.kCALLPTR: return callptr(node)
        case Tack.kENTER: return enter(node)
        case Tack.kLEAVE: return leave(node)
        case Tack.kRET: return ret(node)
        case Tack.kJMP: return jmp(node)
        case Tack.kNOT: return not(node)
        case Tack.kLA: return la(node)
        case Tack.kBZ: return bz(node)
        case Tack.kBNZ: return bnz(node)
        case Tack.kLOAD: return load(node)
        case Tack.kSTORE: return store(node)
        case Tack.kSTSTR: return ststr(node)
        case Tack.kMEMCPY: return memcpy(node)
        case Tack.kALLOCA: return alloca(node)
        case Tack.kFREE: return free(node)
        case Tack.kANDI16: return andi16(node)
        case Tack.kADDI16: return addi16(node)
        case Tack.kSUBI16: return subi16(node)
        case Tack.kMULI16: return muli16(node)
        case Tack.kLI16: return li16(node)
        case Tack.kLIU16: return liu16(node)
        case Tack.kAND16: return and16(node)
        case Tack.kOR16: return or16(node)
        case Tack.kXOR16: return xor16(node)
        case Tack.kNEG16: return neg16(node)
        case Tack.kADD16: return add16(node)
        case Tack.kSUB16: return sub16(node)
        case Tack.kMUL16: return mul16(node)
        case Tack.kDIV16: return div16(node)
        case Tack.kMOD16: return mod16(node)
        case Tack.kLSL16: return lsl16(node)
        case Tack.kLSR16: return lsr16(node)
        case Tack.kEQ16: return eq16(node)
        case Tack.kNE16: return ne16(node)
        case Tack.kLT16: return lt16(node)
        case Tack.kGE16: return ge16(node)
        case Tack.kLE16: return le16(node)
        case Tack.kGT16: return gt16(node)
        case Tack.kLI8: return li8(node)
        case Tack.kAND8: return and8(node)
        case Tack.kOR8: return or8(node)
        case Tack.kXOR8: return xor8(node)
        case Tack.kNEG8: return neg8(node)
        case Tack.kADD8: return add8(node)
        case Tack.kSUB8: return sub8(node)
        case Tack.kMUL8: return mul8(node)
        case Tack.kDIV8: return div8(node)
        case Tack.kMOD8: return mod8(node)
        case Tack.kLSL8: return lsl8(node)
        case Tack.kLSR8: return lsr8(node)
        case Tack.kEQ8: return eq8(node)
        case Tack.kNE8: return ne8(node)
        case Tack.kLT8: return lt8(node)
        case Tack.kGE8: return ge8(node)
        case Tack.kLE8: return le8(node)
        case Tack.kGT8: return gt8(node)
        default: return node
        }
    }
    
    func call(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kCALL, parameters: node.parameters)
    }
    
    func callptr(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kCALLPTR, parameters: corresponding(parameters: node.parameters))
    }
    
    func enter(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kENTER, parameters: corresponding(parameters: node.parameters))
    }
    
    func leave(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLEAVE, parameters: corresponding(parameters: node.parameters))
    }
    
    func ret(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kRET, parameters: corresponding(parameters: node.parameters))
    }
    
    func jmp(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kJMP, parameters: node.parameters)
    }
    
    func not(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        assert(node.parameters.count == 2)
        let src = corresponding((node.parameters[1] as! ParameterIdentifier).value)
        let tmp = nextRegister()
        let dst = corresponding((node.parameters[0] as! ParameterIdentifier).value)
        
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kNOT, parameters: [
                ParameterIdentifier(tmp),
                ParameterIdentifier(src)
            ]),
            InstructionNode(instruction: kANDI, parameters: [
                ParameterIdentifier(dst),
                ParameterIdentifier(tmp),
                ParameterNumber(1)
            ])
        ])
    }
    
    func la(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLA, parameters: node.parameters)
    }
    
    func bz(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        assert(node.parameters.count == 2)
        let test = corresponding((node.parameters[0] as! ParameterIdentifier).value)
        let label = node.parameters[1]
        
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kCMPI, parameters: [
                ParameterIdentifier(test),
                ParameterNumber(0)
            ]),
            InstructionNode(instruction: kBEQ, parameters: [
                label
            ])
        ])
    }
    
    func bnz(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        assert(node.parameters.count == 2)
        let test = corresponding((node.parameters[0] as! ParameterIdentifier).value)
        let label = node.parameters[1]
        
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kCMPI, parameters: [
                ParameterIdentifier(test),
                ParameterNumber(0)
            ]),
            InstructionNode(instruction: kBNE, parameters: [
                label
            ])
        ])
    }
    
    func load(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        if node.parameters.count == 3, let imm = (node.parameters[2] as? ParameterNumber)?.value, (imm > 15 || imm < -16) {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let addr1 = corresponding(param: node.parameters[1])
            let offset = nextRegister()
            let addr2 = nextRegister()
            let dst = corresponding(param: node.parameters[0])
            
            return Seq(children: [
                InstructionNode(instruction: kLIU, parameters:[
                    ParameterIdentifier(offset),
                    ParameterNumber(Int(imm16 & 0x00ff))
                ]),
                InstructionNode(instruction: kLUI, parameters:[
                    ParameterIdentifier(offset),
                    ParameterNumber(Int((imm16 & 0xff00) >> 8))
                ]),
                InstructionNode(instruction: kADD, parameters:[
                    ParameterIdentifier(addr2),
                    ParameterIdentifier(offset),
                    addr1
                ]),
                InstructionNode(instruction: kLOAD, parameters:[
                    dst,
                    ParameterIdentifier(addr2)
                ])
            ])
        }
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLOAD, parameters: corresponding(parameters: node.parameters))
    }
    
    func store(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        if node.parameters.count == 3, let imm = (node.parameters[2] as? ParameterNumber)?.value, (imm > 15 || imm < -16) {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let addr1 = corresponding(param: node.parameters[1])
            let offset = nextRegister()
            let addr2 = nextRegister()
            let src = corresponding(param: node.parameters[0])
            
            return Seq(children: [
                InstructionNode(instruction: kLIU, parameters:[
                    ParameterIdentifier(offset),
                    ParameterNumber(Int(imm16 & 0x00ff))
                ]),
                InstructionNode(instruction: kLUI, parameters:[
                    ParameterIdentifier(offset),
                    ParameterNumber(Int((imm16 & 0xff00) >> 8))
                ]),
                InstructionNode(instruction: kADD, parameters:[
                    ParameterIdentifier(addr2),
                    ParameterIdentifier(offset),
                    addr1
                ]),
                InstructionNode(instruction: kSTORE, parameters:[
                    src,
                    ParameterIdentifier(addr2)
                ])
            ])
        }
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kSTORE, parameters: corresponding(parameters: node.parameters))
    }
    
    func ststr(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func memcpy(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func alloca(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func free(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    fileprivate func opWithImm16(_ node: InstructionNode, _ rrr: String, _ rri: String) -> AbstractSyntaxTreeNode? {
        assert(node.parameters.count == 3)
        let imm = (node.parameters[2] as! ParameterNumber).value
        if imm > 15 || imm < -16 {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let left = corresponding(param: node.parameters[1])
            let right = nextRegister()
            let dst = corresponding(param: node.parameters[0])
            
            return Seq(children: [
                InstructionNode(instruction: kLIU, parameters:[
                    ParameterIdentifier(right),
                    ParameterNumber(Int(imm16 & 0x00ff))
                ]),
                InstructionNode(instruction: kLUI, parameters:[
                    ParameterIdentifier(right),
                    ParameterNumber(Int((imm16 & 0xff00) >> 8))
                ]),
                InstructionNode(instruction: rrr, parameters:[
                    dst,
                    left,
                    ParameterIdentifier(right)
                ])
            ])
        }
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: rri, parameters: corresponding(parameters: node.parameters))
    }
    
    func andi16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return opWithImm16(node, kAND, kANDI)
    }
    
    func addi16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return opWithImm16(node, kADD, kADDI)
    }
    
    func subi16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return opWithImm16(node, kSUB, kSUBI)
    }
    
    func muli16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        assert(node.parameters.count == 3)
        let imm = (node.parameters[2] as! ParameterNumber).value
        
        if imm == 0 {
            _ = corresponding(param: node.parameters[1])
            let dst = corresponding(param: node.parameters[0])
            
            return InstructionNode(instruction: kLI, parameters:[
                dst,
                ParameterNumber(0)
            ])
        }
        else if imm == 1 {
            let src = corresponding(param: node.parameters[1])
            let dst = corresponding(param: node.parameters[0])
            
            return Seq(children: [
                InstructionNode(instruction: kADDI, parameters:[
                    dst,
                    src,
                    ParameterNumber(0)
                ])
            ])
        }
        else if imm == -1 {
            let src = corresponding(param: node.parameters[1])
            let intermediate = ParameterIdentifier(nextRegister())
            let dst = corresponding(param: node.parameters[0])
            
            return Seq(children: [
                InstructionNode(instruction: kNOT, parameters:[
                    intermediate,
                    src
                ]),
                InstructionNode(instruction: kADDI, parameters:[
                    dst,
                    intermediate,
                    ParameterNumber(1)
                ])
            ])
        }
        
        return muli16_pow2(node, imm)
    }
    
    fileprivate func muli16_pow2(_ node: InstructionNode, _ imm: Int) -> AbstractSyntaxTreeNode? {
        // Adding a number to itself is a quick way to multiply by two.
        // Decompose the multiplication into the sum of powers of two to take
        // advantage of this fact.
        assert(registerMap[(node.parameters[0] as! ParameterIdentifier).value] == nil)
        
        var children: [InstructionNode] = []
        let mustNegateAtEnd = imm < 0
        var multiplicand = abs(imm)
        assert(multiplicand > 1)
        let multiplier = corresponding(param: node.parameters[1])
        var resultStack: [ParameterIdentifier] = []
        
        while multiplicand > 1 {
            let exponent = Int(log2(Float(multiplicand)))
            multiplicand -= (pow(2, exponent) as NSDecimalNumber).intValue
            resultStack.append(ParameterIdentifier(nextRegister()))
            
            children += [
                InstructionNode(instruction: kADD, parameters:[
                    resultStack[resultStack.count - 1],
                    multiplier,
                    multiplier,
                ])
            ]
            for _ in 1..<exponent {
                children += [
                    InstructionNode(instruction: kADD, parameters:[
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
                InstructionNode(instruction: kADD, parameters:[
                    sum,
                    resultStack[0],
                    resultStack[1],
                ])
            ]
            for component in resultStack[2..<resultStack.count] {
                children += [
                    InstructionNode(instruction: kADD, parameters:[
                        sum,
                        sum,
                        component,
                    ])
                ]
            }
        }
        
        if multiplicand == 1 {
            children += [
                InstructionNode(instruction: kADD, parameters:[
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
                InstructionNode(instruction: kNOT, parameters:[
                    t1,
                    sum
                ]),
                InstructionNode(instruction: kADDI, parameters:[
                    t2,
                    t1,
                    ParameterNumber(1)
                ])
            ]
            sum = t2
        }
        
        registerMap[(node.parameters[0] as! ParameterIdentifier).value] = sum.value
        
        return Seq(children: children)
    }
    
    func li16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        if let imm = (node.parameters[1] as? ParameterNumber)?.value, (imm > 127 || imm < -128) {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let dst = corresponding(param: node.parameters[0])
            let lower = Int(imm16 & 0x00ff)
            let upper = Int((imm16 & 0xff00) >> 8)
            
            if upper != 0 {
                return Seq(children: [
                    InstructionNode(instruction: kLIU, parameters:[
                        dst,
                        ParameterNumber(lower)
                    ]),
                    InstructionNode(instruction: kLUI, parameters:[
                        dst,
                        ParameterNumber(upper)
                    ])
                ])
            }
            else {
                return InstructionNode(instruction: kLIU, parameters:[
                    dst,
                    ParameterNumber(lower)
                ])
            }
        }
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLI, parameters: corresponding(parameters: node.parameters))
    }
    
    func liu16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        if let imm = (node.parameters[1] as? ParameterNumber)?.value, imm > 255 {
            let imm16 = UInt16(imm)
            let dst = corresponding(param: node.parameters[0])
            let lower = Int(imm16 & 0x00ff)
            let upper = Int((imm16 & 0xff00) >> 8)
            
            if upper != 0 {
                return Seq(children: [
                    InstructionNode(instruction: kLIU, parameters:[
                        dst,
                        ParameterNumber(lower)
                    ]),
                    InstructionNode(instruction: kLUI, parameters:[
                        dst,
                        ParameterNumber(upper)
                    ])
                ])
            }
            else {
                return InstructionNode(instruction: kLIU, parameters:[
                    dst,
                    ParameterNumber(lower)
                ])
            }
        }
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLIU, parameters: corresponding(parameters: node.parameters))
    }
    
    func and16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kAND, parameters: corresponding(parameters: node.parameters))
    }
    
    func or16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kOR, parameters: corresponding(parameters: node.parameters))
    }
    
    func xor16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kXOR, parameters: corresponding(parameters: node.parameters))
    }
    
    func neg16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kNOT, parameters: corresponding(parameters: node.parameters))
    }
    
    func add16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kADD, parameters: corresponding(parameters: node.parameters))
    }
    
    func sub16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kSUB, parameters: corresponding(parameters: node.parameters))
    }
    
    fileprivate let labelMaker = LabelMaker(prefix: ".LL")
    
    func mul16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        let right = corresponding(param: node.parameters[2])
        let left = corresponding(param: node.parameters[1])
        let counter = ParameterIdentifier(nextRegister())
        let result = corresponding(param: node.parameters[0])
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLI, parameters: [
                result,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kADDI, parameters: [
                counter,
                left,
                ParameterNumber(0)
            ]),
            LabelDeclaration(identifier: head),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kCMPI, parameters: [
                counter,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kBEQ, parameters: [
                ParameterIdentifier(tail)
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kADD, parameters: [
                result,
                result,
                right
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kSUBI, parameters: [
                counter,
                counter,
                ParameterNumber(1)
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kJMP, parameters: [
                ParameterIdentifier(head)
            ]),
            LabelDeclaration(identifier: tail)
        ])
    }
    
    func div16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        let right = corresponding(param: node.parameters[2])
        let left = corresponding(param: node.parameters[1])
        let tempLeft = ParameterIdentifier(nextRegister())
        let result = corresponding(param: node.parameters[0])
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLI, parameters: [
                result,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kCMPI, parameters: [
                right,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kBEQ, parameters: [
                ParameterIdentifier(tail)
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kADDI, parameters: [
                tempLeft,
                left,
                ParameterNumber(0)
            ]),
            LabelDeclaration(identifier: head),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kCMP, parameters: [
                tempLeft,
                right
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kBLT, parameters: [
                ParameterIdentifier(tail)
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kSUB, parameters: [
                tempLeft,
                tempLeft,
                right
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kADDI, parameters: [
                result,
                result,
                ParameterNumber(1)
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kJMP, parameters: [
                ParameterIdentifier(head)
            ]),
            LabelDeclaration(identifier: tail)
        ])
    }
    
    func mod16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        let right = corresponding(param: node.parameters[2])
        let left = corresponding(param: node.parameters[1])
        let tempLeft = corresponding(param: node.parameters[0])
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kADDI, parameters: [
                tempLeft,
                left,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kCMPI, parameters: [
                right,
                ParameterNumber(0)
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kBEQ, parameters: [
                ParameterIdentifier(tail)
            ]),
            LabelDeclaration(identifier: head),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kCMP, parameters: [
                tempLeft,
                right
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kBLT, parameters: [
                ParameterIdentifier(tail)
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kSUB, parameters: [
                tempLeft,
                tempLeft,
                right
            ]),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kJMP, parameters: [
                ParameterIdentifier(head)
            ]),
            LabelDeclaration(identifier: tail)
        ])
    }
    
    func lsl16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        let N = 16
        let b = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let n = corresponding(param: node.parameters[2])
        let temp = ParameterIdentifier(nextRegister())
        let mask1 = ParameterIdentifier(nextRegister())
        let mask2 = ParameterIdentifier(nextRegister())
        let i = ParameterIdentifier(nextRegister())
        let head_shift = ParameterIdentifier(labelMaker.next())
        let tail_shift = ParameterIdentifier(labelMaker.next())
        let head_body = ParameterIdentifier(labelMaker.next())
        let skip = ParameterIdentifier(labelMaker.next())
        let tail_body = ParameterIdentifier(labelMaker.next())
        
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kLIU, parameters: [b, ParameterNumber(0)]),
            InstructionNode(instruction: kLIU, parameters: [mask1, ParameterNumber(1)]),
            InstructionNode(instruction: kLIU, parameters: [mask2, ParameterNumber(1)]),
            InstructionNode(instruction: kADDI, parameters: [temp, n, ParameterNumber(0)]),
            LabelDeclaration(head_shift),
            InstructionNode(instruction: kCMPI, parameters: [temp, ParameterNumber(0)]),
            InstructionNode(instruction: kBEQ, parameter: tail_shift),
            InstructionNode(instruction: kADD, parameters: [mask2, mask2, mask2]),
            InstructionNode(instruction: kSUBI, parameters: [temp, temp, ParameterNumber(1)]),
            InstructionNode(instruction: kJMP, parameter: head_shift),
            LabelDeclaration(tail_shift),
            InstructionNode(instruction: kLIU, parameters: [i, ParameterNumber(0)]),
            LabelDeclaration(head_body),
            InstructionNode(instruction: kLIU, parameters: [temp, ParameterNumber(N)]),
            InstructionNode(instruction: kSUB, parameters: [temp, temp, n]),
            InstructionNode(instruction: kCMP, parameters: [i, temp]),
            InstructionNode(instruction: kBGE, parameter: tail_body),
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
    
    func lsr16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        let N = 16
        let b = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let n = corresponding(param: node.parameters[2])
        let temp = ParameterIdentifier(nextRegister())
        let mask1 = ParameterIdentifier(nextRegister())
        let mask2 = ParameterIdentifier(nextRegister())
        let i = ParameterIdentifier(nextRegister())
        let head_shift = ParameterIdentifier(labelMaker.next())
        let tail_shift = ParameterIdentifier(labelMaker.next())
        let head_body = ParameterIdentifier(labelMaker.next())
        let skip = ParameterIdentifier(labelMaker.next())
        let tail_body = ParameterIdentifier(labelMaker.next())
        
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kLIU, parameters: [b, ParameterNumber(0)]),
            InstructionNode(instruction: kLIU, parameters: [mask1, ParameterNumber(1)]),
            InstructionNode(instruction: kLIU, parameters: [mask2, ParameterNumber(1)]),
            InstructionNode(instruction: kADDI, parameters: [temp, n, ParameterNumber(0)]),
            LabelDeclaration(head_shift),
            InstructionNode(instruction: kCMPI, parameters: [temp, ParameterNumber(0)]),
            InstructionNode(instruction: kBEQ, parameter: tail_shift),
            InstructionNode(instruction: kADD, parameters: [mask2, mask2, mask2]),
            InstructionNode(instruction: kSUBI, parameters: [temp, temp, ParameterNumber(1)]),
            InstructionNode(instruction: kJMP, parameter: head_shift),
            LabelDeclaration(tail_shift),
            InstructionNode(instruction: kLIU, parameters: [i, ParameterNumber(0)]),
            LabelDeclaration(head_body),
            InstructionNode(instruction: kLIU, parameters: [temp, ParameterNumber(N)]),
            InstructionNode(instruction: kSUB, parameters: [temp, temp, n]),
            InstructionNode(instruction: kCMP, parameters: [i, temp]),
            InstructionNode(instruction: kBGE, parameter: tail_body),
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
    
    func eq16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func ne16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func lt16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func ge16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func le16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func gt16(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func li8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func and8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func or8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func xor8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func neg8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func add8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func sub8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func mul8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func div8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func mod8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func lsl8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func lsr8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func eq8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func ne8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func lt8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func ge8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func le8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
    
    func gt8(_ node: InstructionNode) -> AbstractSyntaxTreeNode? {
        fatalError("unimplemented")
    }
}
