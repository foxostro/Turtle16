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
    
    public override func compile(tack node: TackInstructionNode) throws -> AbstractSyntaxTreeNode? {
        switch node.instruction {
        case .hlt: return hlt(node)
        case .call: return call(node)
        case .callptr: return callptr(node)
        case .enter: return enter(node)
        case .leave: return leave(node)
        case .ret: return ret(node)
        case .jmp: return jmp(node)
        case .not: return not(node)
        case .la: return la(node)
        case .bz: return bz(node)
        case .bnz: return bnz(node)
        case .load: return load(node)
        case .store: return store(node)
        case .ststr: return ststr(node)
        case .memcpy: return memcpy(node)
        case .alloca: return alloca(node)
        case .free: return free(node)
        case .andi16: return andi16(node)
        case .addi16: return addi16(node)
        case .subi16: return subi16(node)
        case .muli16: return muli16(node)
        case .li16: return li16(node)
        case .liu16: return liu16(node)
        case .and16: return and16(node)
        case .or16: return or16(node)
        case .xor16: return xor16(node)
        case .neg16: return neg16(node)
        case .add16: return add16(node)
        case .sub16: return sub16(node)
        case .mul16: return mul16(node)
        case .div16: return div16(node)
        case .mod16: return mod16(node)
        case .lsl16: return lsl16(node)
        case .lsr16: return lsr16(node)
        case .eq16: return eq16(node)
        case .ne16: return ne16(node)
        case .lt16: return lt16(node)
        case .ge16: return ge16(node)
        case .le16: return le16(node)
        case .gt16: return gt16(node)
        case .ltu16: return ltu16(node)
        case .geu16: return geu16(node)
        case .leu16: return leu16(node)
        case .gtu16: return gtu16(node)
        case .li8: return li8(node)
        case .liu8: return liu8(node)
        case .and8: return and8(node)
        case .or8: return or8(node)
        case .xor8: return xor8(node)
        case .neg8: return neg8(node)
        case .add8: return add8(node)
        case .sub8: return sub8(node)
        case .mul8: return mul8(node)
        case .div8: return div8(node)
        case .mod8: return mod8(node)
        case .lsl8: return lsl8(node)
        case .lsr8: return lsr8(node)
        case .eq8: return eq8(node)
        case .ne8: return ne8(node)
        case .lt8: return lt8(node)
        case .ge8: return ge8(node)
        case .le8: return le8(node)
        case .gt8: return gt8(node)
        case .ltu8: return ltu8(node)
        case .geu8: return geu8(node)
        case .leu8: return leu8(node)
        case .gtu8: return gtu8(node)
        case .sxt8: return sxt8(node)
        }
    }
    
    func hlt(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kNOP, parameters: node.parameters),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kHLT, parameters: node.parameters)
        ])
    }
    
    func call(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kCALL, parameters: node.parameters)
    }
    
    func callptr(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kCALLPTR, parameters: corresponding(parameters: node.parameters))
    }
    
    func enter(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kENTER, parameters: corresponding(parameters: node.parameters))
    }
    
    func leave(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLEAVE, parameters: corresponding(parameters: node.parameters))
    }
    
    func ret(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kRET, parameters: corresponding(parameters: node.parameters))
    }
    
    func jmp(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kJMP, parameters: node.parameters)
    }
    
    func not(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
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
    
    func la(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let dst = corresponding(param: node.parameters[0])
        let tgt = node.parameters[1]
        let r = InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLA, parameters: [dst, tgt])
        return r
    }
    
    func bz(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
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
    
    func bnz(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
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
    
    func load(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        if node.parameters.count == 3, let imm = (node.parameters[2] as? ParameterNumber)?.value, (imm > 15 || imm < -16) {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let addr1 = corresponding(param: node.parameters[1])
            let offset = nextRegister()
            let addr2 = nextRegister()
            let dst = corresponding(param: node.parameters[0])
            
            return Seq(children: [
                InstructionNode(instruction: kLI, parameters:[
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
    
    func store(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        if node.parameters.count == 3, let imm = (node.parameters[2] as? ParameterNumber)?.value, (imm > 15 || imm < -16) {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let addr1 = corresponding(param: node.parameters[1])
            let offset = nextRegister()
            let addr2 = nextRegister()
            let src = corresponding(param: node.parameters[0])
            
            return Seq(children: [
                InstructionNode(instruction: kLI, parameters:[
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
    
    func ststr(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        // TODO: Use the offset parameter of the STORE instruction to improve STSTR performance.
        let originalDst = corresponding(param: node.parameters[0])
        let dst = ParameterIdentifier(nextRegister())
        let src = ParameterIdentifier(nextRegister())
        var children: [AbstractSyntaxTreeNode] = [
            InstructionNode(instruction: kADDI, parameters: [dst, originalDst, ParameterNumber(0)])
        ]
        let str = node.parameters[1] as! ParameterString
        if str.value == "" {
            return nil
        }
        for character in str.value.utf8 {
            let imm16 = UInt16(character)
            let lower = Int(imm16 & 0x00ff)
            let upper = Int((imm16 & 0xff00) >> 8)
            children += [
                InstructionNode(instruction: kLI,    parameters:[src, ParameterNumber(lower)]),
                InstructionNode(instruction: kLUI,   parameters:[src, ParameterNumber(upper)]),
                InstructionNode(instruction: kSTORE, parameters: [src, dst, ParameterNumber(0)]),
                InstructionNode(instruction: kADDI,  parameters: [dst, dst, ParameterNumber(1)])
            ]
        }
        return Seq(children: children)
    }
    
    func memcpy(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        // TODO: Use the offset parameter of the STORE instruction to improve MEMCPY performance.
        let originalDst = corresponding(param: node.parameters[0])
        let originalSrc = corresponding(param: node.parameters[1])
        let numberOfWords = (node.parameters[2] as! ParameterNumber).value
        switch numberOfWords {
        case 0:
            return Seq()
            
        case 1:
            let temp = ParameterIdentifier(nextRegister())
            var children: [AbstractSyntaxTreeNode] = []
            for _ in 0..<numberOfWords {
                children += [
                    InstructionNode(instruction: kLOAD, parameters: [temp, originalSrc, ParameterNumber(0)]),
                    InstructionNode(instruction: kSTORE, parameters: [temp, originalDst, ParameterNumber(0)])
                ]
            }
            return Seq(children: children)
            
        default:
            let dst = ParameterIdentifier(nextRegister())
            let src = ParameterIdentifier(nextRegister())
            let temp = ParameterIdentifier(nextRegister())
            var children: [AbstractSyntaxTreeNode] = [
                InstructionNode(instruction: kADDI, parameters: [dst, originalDst, ParameterNumber(0)]),
                InstructionNode(instruction: kADDI, parameters: [src, originalSrc, ParameterNumber(0)])
            ]
            for _ in 0..<numberOfWords {
                children += [
                    InstructionNode(instruction: kLOAD, parameters: [temp, src, ParameterNumber(0)]),
                    InstructionNode(instruction: kSTORE, parameters: [temp, dst, ParameterNumber(0)]),
                    InstructionNode(instruction: kADDI,  parameters: [dst, dst, ParameterNumber(1)]),
                    InstructionNode(instruction: kADDI,  parameters: [src, src, ParameterNumber(1)])
                ]
            }
            return Seq(children: children)
        }
    }
    
    func alloca(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return Seq(children: [
            subi16(TackInstructionNode(instruction: .subi16, parameters: [
                ParameterIdentifier("sp"),
                ParameterIdentifier("sp"),
                node.parameters[1]
            ])) ?? Seq(),
            InstructionNode(instruction: kADDI, parameters:[
                corresponding(param: node.parameters[0]),
                ParameterIdentifier("sp"),
                ParameterNumber(0)
            ])
        ])
    }
    
    func free(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return addi16(TackInstructionNode(instruction: .addi16, parameters: [
            ParameterIdentifier("sp"),
            ParameterIdentifier("sp"),
            node.parameters[0]
        ]))
    }
    
    fileprivate func opWithImm16(_ node: TackInstructionNode, _ rrr: String, _ rri: String) -> AbstractSyntaxTreeNode? {
        assert(node.parameters.count == 3)
        let imm = (node.parameters[2] as! ParameterNumber).value
        if imm > 15 || imm < -16 {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let left = corresponding(param: node.parameters[1])
            let right = nextRegister()
            let dst = corresponding(param: node.parameters[0])
            
            return Seq(children: [
                InstructionNode(instruction: kLI, parameters:[
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
    
    func andi16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return opWithImm16(node, kAND, kANDI)
    }
    
    func addi16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return opWithImm16(node, kADD, kADDI)
    }
    
    func subi16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return opWithImm16(node, kSUB, kSUBI)
    }
    
    func muli16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
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
    
    fileprivate func muli16_pow2(_ node: TackInstructionNode, _ imm: Int) -> AbstractSyntaxTreeNode? {
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
    
    func li16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let imm = (node.parameters[1] as! ParameterNumber).value
        if imm >= Int8.min && imm <= Int8.max {
            return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLI, parameters: corresponding(parameters: node.parameters))
        }
        else {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let dst = corresponding(param: node.parameters[0])
            let lower = Int(imm16 & 0x00ff)
            let upper = Int((imm16 & 0xff00) >> 8)
            
            return Seq(children: [
                InstructionNode(instruction: kLI, parameters:[
                    dst,
                    ParameterNumber(lower)
                ]),
                InstructionNode(instruction: kLUI, parameters:[
                    dst,
                    ParameterNumber(upper)
                ])
            ])
        }
    }
    
    func liu16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        if let imm = (node.parameters[1] as? ParameterNumber)?.value, imm > 255 {
            let imm16 = UInt16(imm)
            let dst = corresponding(param: node.parameters[0])
            let lower = Int(imm16 & 0x00ff)
            let upper = Int((imm16 & 0xff00) >> 8)
            
            return Seq(children: [
                InstructionNode(instruction: kLI, parameters:[
                    dst,
                    ParameterNumber(lower)
                ]),
                InstructionNode(instruction: kLUI, parameters:[
                    dst,
                    ParameterNumber(upper)
                ])
            ])
        }
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLI, parameters: corresponding(parameters: node.parameters))
    }
    
    func and16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kAND, parameters: corresponding(parameters: node.parameters))
    }
    
    func or16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kOR, parameters: corresponding(parameters: node.parameters))
    }
    
    func xor16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kXOR, parameters: corresponding(parameters: node.parameters))
    }
    
    func neg16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kNOT, parameters: corresponding(parameters: node.parameters))
    }
    
    func add16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kADD, parameters: corresponding(parameters: node.parameters))
    }
    
    func sub16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kSUB, parameters: corresponding(parameters: node.parameters))
    }
    
    fileprivate let labelMaker = LabelMaker(prefix: ".LL")
    
    func mul16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
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
    
    func div16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
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
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kBLTU, parameters: [
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
    
    func mod16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
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
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kBLTU, parameters: [
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
    
    func lsl16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
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
    
    func lsr16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
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
    
    func eq16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBEQ, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func ne16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBNE, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func lt16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBLT, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func ge16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(instruction: kBLT, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func le16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(instruction: kBGT, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func gt16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBGT, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func ltu16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBLTU, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func geu16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(instruction: kBLTU, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func leu16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(instruction: kBGTU, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func gtu16(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBGTU, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func li8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        // The hardware always sign-extends this immediate value.
        let imm = node.parameters[1] as! ParameterNumber
        assert(imm.value >= -128 && imm.value < 128)
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLI, parameters: corresponding(parameters: node.parameters))
    }
    
    func liu8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        // The hardware always sign-extends this immediate value. We may need
        // an extra instruction to circumvent this behavior.
        let imm = node.parameters[1] as! ParameterNumber
        assert(imm.value >= 0 && imm.value < 256)
        if imm.value > 127 {
            return Seq(children: [
                InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLI, parameters: corresponding(parameters: node.parameters)),
                InstructionNode(instruction: kLUI, parameters: [
                    corresponding(param: node.parameters[0]),
                    ParameterNumber(0)
                ])
            ])
        }
        else {
            return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLI, parameters: corresponding(parameters: node.parameters))
        }
    }
    
    func and8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return Seq(children: [
            InstructionNode(instruction: kAND, parameters: corresponding(parameters: node.parameters)),
            InstructionNode(instruction: kLUI, parameters: [
                corresponding(param: node.parameters[0]),
                ParameterNumber(0)
            ])
        ])
    }
    
    func or8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return Seq(children: [
            InstructionNode(instruction: kOR, parameters: corresponding(parameters: node.parameters)),
            InstructionNode(instruction: kLUI, parameters: [
                corresponding(param: node.parameters[0]),
                ParameterNumber(0)
            ])
        ])
    }
    
    func xor8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return Seq(children: [
            InstructionNode(instruction: kXOR, parameters: corresponding(parameters: node.parameters)),
            InstructionNode(instruction: kLUI, parameters: [
                corresponding(param: node.parameters[0]),
                ParameterNumber(0)
            ])
        ])
    }
    
    func neg8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return Seq(children: [
            InstructionNode(instruction: kNOT, parameters: corresponding(parameters: node.parameters)),
            InstructionNode(instruction: kLUI, parameters: [
                corresponding(param: node.parameters[0]),
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
    
    func add8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let b = corresponding(param: node.parameters[2])
        let a = corresponding(param: node.parameters[1])
        let c = corresponding(param: node.parameters[0])
        
        return Seq(children: [
            InstructionNode(instruction: kADD, parameters: [c, a, b]),
            signExtend8(c)
        ])
    }
    
    func sub8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let b = corresponding(param: node.parameters[2])
        let a = corresponding(param: node.parameters[1])
        let c = corresponding(param: node.parameters[0])
        
        return Seq(children: [
            InstructionNode(instruction: kSUB, parameters: [c, a, b]),
            signExtend8(c)
        ])
    }
    
    func mul8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return Seq(children: [
            mul16(TackInstructionNode(instruction: .mul16, parameters: node.parameters))!,
            signExtend8(node.parameters[0])
        ])
    }
    
    func div8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return Seq(children: [
            div16(TackInstructionNode(instruction: .div16, parameters: node.parameters))!,
            signExtend8(node.parameters[0])
        ])
    }
    
    func mod8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return Seq(children: [
            mod16(TackInstructionNode(instruction: .mod16, parameters: node.parameters))!,
            signExtend8(node.parameters[0])
        ])
    }
    
    func lsl8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return Seq(children: [
            lsl16(TackInstructionNode(instruction: .lsl16, parameters: node.parameters))!,
            InstructionNode(instruction: kLUI, parameters: [
                node.parameters[0],
                ParameterNumber(0)
            ])
        ])
    }
    
    func lsr8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        return Seq(children: [
            lsr16(TackInstructionNode(instruction: .lsr16, parameters: node.parameters))!,
            InstructionNode(instruction: kLUI, parameters: [
                node.parameters[0],
                ParameterNumber(0)
            ])
        ])
    }
    
    func eq8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBEQ, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func ne8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBNE, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func lt8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBLT, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func ge8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(instruction: kBLT, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func le8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(instruction: kBGT, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func gt8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBGT, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func ltu8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBLTU, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func geu8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(instruction: kBLTU, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func leu8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            InstructionNode(instruction: kBGTU, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func gtu8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        let c = corresponding(param: node.parameters[0])
        let a = corresponding(param: node.parameters[1])
        let b = corresponding(param: node.parameters[2])
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            signExtend8(a),
            signExtend8(b),
            InstructionNode(instruction: kCMP, parameters: [a, b]),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
            InstructionNode(instruction: kBGTU, parameter: ll0),
            InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
            LabelDeclaration(ll0)
        ])
    }
    
    func sxt8(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        // Take lower eight-bits of the value in the source register, sign-
        // extend this to sixteen bits, and write the result to the destination
        // register.
        let dst = corresponding(param: node.parameters[0])
        let src = corresponding(param: node.parameters[1])
        let temp = ParameterIdentifier(nextRegister())
        return Seq(children: [
            InstructionNode(instruction: kADDI, parameters: [
                dst,
                src,
                ParameterNumber(0)
            ]),
            InstructionNode(instruction: kLI, parameters: [
                temp,
                ParameterNumber(0x80)
            ]),
            InstructionNode(instruction: kLUI, parameters: [
                temp,
                ParameterNumber(0x00)
            ]),
            InstructionNode(instruction: kLUI, parameters: [
                dst,
                ParameterNumber(0)
            ]),
            InstructionNode(instruction: kXOR, parameters: [
                dst,
                dst,
                temp
            ]),
            InstructionNode(instruction: kSUB, parameters: [
                dst,
                dst,
                temp
            ])
        ])
    }
}
