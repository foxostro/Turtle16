//
//  TackToTurtle16Compiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/19/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleSimulatorCore

public final class TackToTurtle16Compiler: CompilerPass {
    public override func visit(_ node0: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        flatten(try super.visit(node0))
    }

    fileprivate func flatten(_ node: AbstractSyntaxTreeNode?) -> AbstractSyntaxTreeNode {
        try! CompilerPassFlattenSeq().visit(node)
            ?? Seq(sourceAnchor: node?.sourceAnchor, children: [])
    }

    fileprivate var nextRegisterIndex = 0

    fileprivate func nextRegister() -> String {
        let index = nextRegisterIndex
        nextRegisterIndex = nextRegisterIndex + 1
        return "vr\(index)"
    }

    fileprivate var registerMap: [TackInstruction.Register: String] = [:]

    fileprivate func corresponding(_ tackRegister: TackInstruction.Register) -> ParameterIdentifier
    {
        let asmRegister: String
        switch tackRegister {
        case .p(.sp):
            asmRegister = "sp"

        case .p(.fp):
            asmRegister = "fp"

        case .p(.ra):
            asmRegister = "ra"

        case .p(.p(_)), .w(.w(_)), .b(.b(_)), .o(.o(_)):
            if let r = registerMap[tackRegister] {
                asmRegister = r
            } else {
                asmRegister = nextRegister()
                registerMap[tackRegister] = asmRegister
            }
        }
        return ParameterIdentifier(asmRegister)
    }

    public override func visit(tack node: TackInstructionNode) throws -> AbstractSyntaxTreeNode? {
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
        case .memcpy(let dst, let src, let n): return memcpy(anc, dst, src, n)
        case .alloca(let dst, let n): return alloca(anc, dst, n)
        case .free(let numberOfWords): return free(anc, numberOfWords)
        case .inlineAssembly(let asm): return try inlineAssembly(asm)
        case .syscall(let n, let ptr): return syscall(anc, n, ptr)

        case .bz(let test, let target): return bz(anc, test, target)
        case .bnz(let test, let target): return bnz(anc, test, target)
        case .not(let dst, let src): return not(anc, dst, src)
        case .eqo(let c, let a, let b): return eqo(anc, c, a, b)
        case .neo(let c, let a, let b): return neo(anc, c, a, b)
        case .lio(let dst, let imm): return lio(anc, dst, imm)
        case .lo(let dst, let addr, let offset): return lo(anc, dst, addr, offset)
        case .so(let src, let addr, let offset): return so(anc, src, addr, offset)

        case .eqp(let c, let a, let b): return eqp(anc, c, a, b)
        case .nep(let c, let a, let b): return nep(anc, c, a, b)
        case .lip(let dst, let imm): return lip(anc, dst, imm)
        case .addip(let dst, let left, let imm): return addip(anc, dst, left, imm)
        case .subip(let dst, let left, let imm): return subip(anc, dst, left, imm)
        case .addpw(let c, let a, let b): return addpw(anc, c, a, b)
        case .lp(let dst, let addr, let offset): return lp(anc, dst, addr, offset)
        case .sp(let src, let addr, let offset): return sp(anc, src, addr, offset)

        case .lw(let dst, let addr, let offset): return lw(anc, dst, addr, offset)
        case .sw(let src, let addr, let offset): return sw(anc, src, addr, offset)
        case .bzw(let test, let target): return bzw(anc, test, target)
        case .andiw(let dst, let left, let imm): return andiw(anc, dst, left, imm)
        case .addiw(let dst, let left, let imm): return addiw(anc, dst, left, imm)
        case .subiw(let dst, let left, let imm): return subiw(anc, dst, left, imm)
        case .muliw(let dst, let left, let imm): return muliw(anc, dst, left, imm)
        case .liw(let dst, let imm): return liw(anc, dst, imm)
        case .liuw(let dst, let imm): return liuw(anc, dst, imm)
        case .andw(let c, let a, let b): return andw(anc, c, a, b)
        case .orw(let c, let a, let b): return orw(anc, c, a, b)
        case .xorw(let c, let a, let b): return xorw(anc, c, a, b)
        case .negw(let dst, let src): return negw(anc, dst, src)
        case .addw(let c, let a, let b): return addw(anc, c, a, b)
        case .subw(let c, let a, let b): return subw(anc, c, a, b)
        case .mulw(let c, let a, let b): return mulw(anc, c, a, b)
        case .divw(let c, let a, let b): return divw(anc, c, a, b)
        case .divuw(let c, let a, let b): return divuw(anc, c, a, b)
        case .modw(let c, let a, let b): return mod16(anc, c, a, b)
        case .lslw(let c, let a, let b): return lslw(anc, c, a, b)
        case .lsrw(let c, let a, let b): return lsrw(anc, c, a, b)
        case .eqw(let c, let a, let b): return eqw(anc, c, a, b)
        case .new(let c, let a, let b): return new(anc, c, a, b)
        case .ltw(let c, let a, let b): return ltw(anc, c, a, b)
        case .gew(let c, let a, let b): return gew(anc, c, a, b)
        case .lew(let c, let a, let b): return lew(anc, c, a, b)
        case .gtw(let c, let a, let b): return gtw(anc, c, a, b)
        case .ltuw(let c, let a, let b): return ltuw(anc, c, a, b)
        case .geuw(let c, let a, let b): return geuw(anc, c, a, b)
        case .leuw(let c, let a, let b): return leuw(anc, c, a, b)
        case .gtuw(let c, let a, let b): return gtuw(anc, c, a, b)

        case .lb(let dst, let addr, let offset): return lb(anc, dst, addr, offset)
        case .sb(let src, let addr, let offset): return sb(anc, src, addr, offset)
        case .lib(let dst, let imm): return li8(anc, dst, imm)
        case .liub(let dst, let imm): return liu8(anc, dst, imm)
        case .andb(let c, let a, let b): return and8(anc, c, a, b)
        case .orb(let c, let a, let b): return or8(anc, c, a, b)
        case .xorb(let c, let a, let b): return xor8(anc, c, a, b)
        case .negb(let dst, let src): return neg8(anc, dst, src)
        case .addb(let c, let a, let b): return add8(anc, c, a, b)
        case .subb(let c, let a, let b): return sub8(anc, c, a, b)
        case .mulb(let c, let a, let b): return mul8(anc, c, a, b)
        case .divub(let c, let a, let b): return divub(anc, c, a, b)
        case .divb(let c, let a, let b): return divb(anc, c, a, b)
        case .modb(let c, let a, let b): return mod8(anc, c, a, b)
        case .lslb(let c, let a, let b): return lsl8(anc, c, a, b)
        case .lsrb(let c, let a, let b): return lsr8(anc, c, a, b)
        case .eqb(let c, let a, let b): return eq8(anc, c, a, b)
        case .neb(let c, let a, let b): return ne8(anc, c, a, b)
        case .ltb(let c, let a, let b): return lt8(anc, c, a, b)
        case .geb(let c, let a, let b): return ge8(anc, c, a, b)
        case .leb(let c, let a, let b): return le8(anc, c, a, b)
        case .gtb(let c, let a, let b): return gt8(anc, c, a, b)
        case .ltub(let c, let a, let b): return ltu8(anc, c, a, b)
        case .geub(let c, let a, let b): return geu8(anc, c, a, b)
        case .leub(let c, let a, let b): return leu8(anc, c, a, b)
        case .gtub(let c, let a, let b): return gtu8(anc, c, a, b)

        case .movsbw(let dst, let src): return movsbw(anc, dst, src)
        case .movswb(let dst, let src): return movswb(anc, dst, src)
        case .movzwb(let dst, let src): return movzwb(anc, dst, src)
        case .movzbw(let dst, let src): return movzbw(anc, dst, src)
        case .bitcast(let dst, let src): return bitcast(anc, dst, src)
        }
    }

    func nop(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        Seq(
            sourceAnchor: node.sourceAnchor,
            children: [
                InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kNOP)
            ]
        )
    }

    func hlt(_ node: TackInstructionNode) -> AbstractSyntaxTreeNode? {
        Seq(
            sourceAnchor: node.sourceAnchor,
            children: [
                InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kNOP),
                InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kHLT),
            ]
        )
    }

    func call(_ sourceAnchor: SourceAnchor?, _ target: String) -> AbstractSyntaxTreeNode? {
        InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kCALL,
            parameter: ParameterIdentifier(target)
        )
    }

    func callptr(
        _ sourceAnchor: SourceAnchor?,
        _ target: TackInstruction.RegisterPointer
    ) -> AbstractSyntaxTreeNode? {
        InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kCALLPTR,
            parameter: corresponding(.p(target))
        )
    }

    func enter(_ sourceAnchor: SourceAnchor?, _ count: Int) -> AbstractSyntaxTreeNode? {
        InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kENTER,
            parameter: ParameterNumber(count)
        )
    }

    func leave(_ sourceAnchor: SourceAnchor?) -> AbstractSyntaxTreeNode? {
        InstructionNode(sourceAnchor: sourceAnchor, instruction: kLEAVE)
    }

    func ret(_ sourceAnchor: SourceAnchor?) -> AbstractSyntaxTreeNode? {
        InstructionNode(sourceAnchor: sourceAnchor, instruction: kRET)
    }

    func jmp(_ sourceAnchor: SourceAnchor?, _ target: String) -> AbstractSyntaxTreeNode? {
        InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kJMP,
            parameter: ParameterIdentifier(target)
        )
    }

    func not(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.RegisterBoolean,
        _ src_: TackInstruction.RegisterBoolean
    ) -> AbstractSyntaxTreeNode? {
        let src = corresponding(.o(src_))
        let tmp = ParameterIdentifier(nextRegister())
        let dst = corresponding(.o(dst_))

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kNOT,
                    parameters: [tmp, src]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kANDI,
                    parameters: [dst, tmp, ParameterNumber(1)]
                ),
            ]
        )
    }

    func eqo(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.RegisterBoolean,
        _ b_: TackInstruction.RegisterBoolean
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.o(b_))
        let a = corresponding(.o(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(instruction: kCMP, parameters: [a, b]),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
                InstructionNode(instruction: kBEQ, parameter: ll0),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
                LabelDeclaration(ll0),
            ]
        )
    }

    func neo(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.RegisterBoolean,
        _ b_: TackInstruction.RegisterBoolean
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.o(b_))
        let a = corresponding(.o(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(instruction: kCMP, parameters: [a, b]),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
                InstructionNode(instruction: kBNE, parameter: ll0),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
                LabelDeclaration(ll0),
            ]
        )
    }

    func la(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.RegisterPointer,
        _ label: String
    ) -> AbstractSyntaxTreeNode? {
        let dst = corresponding(.p(dst_))
        let tgt = ParameterIdentifier(label)
        let r = InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kLA,
            parameters: [dst, tgt]
        )
        return r
    }

    func bz(
        _ sourceAnchor: SourceAnchor?,
        _ test_: TackInstruction.RegisterBoolean,
        _ label: String
    ) -> AbstractSyntaxTreeNode? {
        let test = corresponding(.o(test_))

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMPI,
                    parameters: [
                        test,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBEQ,
                    parameters: [
                        ParameterIdentifier(label)
                    ]
                ),
            ]
        )
    }

    func bzw(
        _ sourceAnchor: SourceAnchor?,
        _ test_: TackInstruction.Register16,
        _ label: String
    ) -> AbstractSyntaxTreeNode? {
        let test = corresponding(.w(test_))

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMPI,
                    parameters: [
                        test,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBEQ,
                    parameters: [
                        ParameterIdentifier(label)
                    ]
                ),
            ]
        )
    }

    func bnz(
        _ sourceAnchor: SourceAnchor?,
        _ test_: TackInstruction.RegisterBoolean,
        _ label: String
    ) -> AbstractSyntaxTreeNode? {
        let test = corresponding(.o(test_))

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMPI,
                    parameters: [
                        test,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBNE,
                    parameters: [
                        ParameterIdentifier(label)
                    ]
                ),
            ]
        )
    }

    func lo(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.RegisterBoolean,
        _ addr_: TackInstruction.RegisterPointer,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        guard imm > 15 || imm < -16 else {
            let addr = corresponding(.p(addr_))
            let dst = corresponding(.o(dst_))
            return InstructionNode(
                sourceAnchor: sourceAnchor,
                instruction: kLOAD,
                parameters: [
                    dst,
                    addr,
                    ParameterNumber(imm),
                ]
            )
        }
        let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
        let addr1 = corresponding(.p(addr_))
        let offset = nextRegister()
        let addr2 = nextRegister()
        let dst = corresponding(.o(dst_))

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int(imm16 & 0x00ff)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int((imm16 & 0xff00) >> 8)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADD,
                    parameters: [
                        ParameterIdentifier(addr2),
                        ParameterIdentifier(offset),
                        addr1,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLOAD,
                    parameters: [
                        dst,
                        ParameterIdentifier(addr2),
                    ]
                ),
            ]
        )
    }

    func lp(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.RegisterPointer,
        _ addr_: TackInstruction.RegisterPointer,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        guard imm > 15 || imm < -16 else {
            let addr = corresponding(.p(addr_))
            let dst = corresponding(.p(dst_))
            return InstructionNode(
                sourceAnchor: sourceAnchor,
                instruction: kLOAD,
                parameters: [
                    dst,
                    addr,
                    ParameterNumber(imm),
                ]
            )
        }
        let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
        let addr1 = corresponding(.p(addr_))
        let offset = nextRegister()
        let addr2 = nextRegister()
        let dst = corresponding(.p(dst_))

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int(imm16 & 0x00ff)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int((imm16 & 0xff00) >> 8)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADD,
                    parameters: [
                        ParameterIdentifier(addr2),
                        ParameterIdentifier(offset),
                        addr1,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLOAD,
                    parameters: [
                        dst,
                        ParameterIdentifier(addr2),
                    ]
                ),
            ]
        )
    }

    func lw(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register16,
        _ addr_: TackInstruction.RegisterPointer,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        guard imm > 15 || imm < -16 else {
            let addr = corresponding(.p(addr_))
            let dst = corresponding(.w(dst_))
            return InstructionNode(
                sourceAnchor: sourceAnchor,
                instruction: kLOAD,
                parameters: [
                    dst,
                    addr,
                    ParameterNumber(imm),
                ]
            )
        }
        let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
        let addr1 = corresponding(.p(addr_))
        let offset = nextRegister()
        let addr2 = nextRegister()
        let dst = corresponding(.w(dst_))

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int(imm16 & 0x00ff)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int((imm16 & 0xff00) >> 8)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADD,
                    parameters: [
                        ParameterIdentifier(addr2),
                        ParameterIdentifier(offset),
                        addr1,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLOAD,
                    parameters: [
                        dst,
                        ParameterIdentifier(addr2),
                    ]
                ),
            ]
        )
    }

    func lb(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register8,
        _ addr_: TackInstruction.RegisterPointer,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        guard imm > 15 || imm < -16 else {
            let addr = corresponding(.p(addr_))
            let dst = corresponding(.b(dst_))
            return InstructionNode(
                sourceAnchor: sourceAnchor,
                instruction: kLOAD,
                parameters: [
                    dst,
                    addr,
                    ParameterNumber(imm),
                ]
            )
        }
        let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
        let addr1 = corresponding(.p(addr_))
        let offset = nextRegister()
        let addr2 = nextRegister()
        let dst = corresponding(.b(dst_))

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int(imm16 & 0x00ff)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int((imm16 & 0xff00) >> 8)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADD,
                    parameters: [
                        ParameterIdentifier(addr2),
                        ParameterIdentifier(offset),
                        addr1,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLOAD,
                    parameters: [
                        dst,
                        ParameterIdentifier(addr2),
                    ]
                ),
            ]
        )
    }

    func so(
        _ sourceAnchor: SourceAnchor?,
        _ src_: TackInstruction.RegisterBoolean,
        _ addr_: TackInstruction.RegisterPointer,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        // TODO: All the store implementations (sp, so, sb, sw) are very similar and can be consolidated
        // TODO: All the load implementations (lp, lo, lb, lw) are very similar and can be consolidated
        guard imm > 15 || imm < -16 else {
            let addr = corresponding(.p(addr_))
            let src = corresponding(.o(src_))
            return InstructionNode(
                sourceAnchor: sourceAnchor,
                instruction: kSTORE,
                parameters: [
                    src,
                    addr,
                    ParameterNumber(imm),
                ]
            )
        }
        let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
        let addr1 = corresponding(.p(addr_))
        let offset = nextRegister()
        let addr2 = nextRegister()
        let src = corresponding(.o(src_))

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int(imm16 & 0x00ff)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int((imm16 & 0xff00) >> 8)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADD,
                    parameters: [
                        ParameterIdentifier(addr2),
                        ParameterIdentifier(offset),
                        addr1,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kSTORE,
                    parameters: [
                        src,
                        ParameterIdentifier(addr2),
                    ]
                ),
            ]
        )
    }

    func sp(
        _ sourceAnchor: SourceAnchor?,
        _ src_: TackInstruction.RegisterPointer,
        _ addr_: TackInstruction.RegisterPointer,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        guard imm > 15 || imm < -16 else {
            let addr = corresponding(.p(addr_))
            let src = corresponding(.p(src_))
            return InstructionNode(
                sourceAnchor: sourceAnchor,
                instruction: kSTORE,
                parameters: [
                    src,
                    addr,
                    ParameterNumber(imm),
                ]
            )
        }
        let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
        let addr1 = corresponding(.p(addr_))
        let offset = nextRegister()
        let addr2 = nextRegister()
        let src = corresponding(.p(src_))

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int(imm16 & 0x00ff)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int((imm16 & 0xff00) >> 8)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADD,
                    parameters: [
                        ParameterIdentifier(addr2),
                        ParameterIdentifier(offset),
                        addr1,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kSTORE,
                    parameters: [
                        src,
                        ParameterIdentifier(addr2),
                    ]
                ),
            ]
        )
    }

    func sw(
        _ sourceAnchor: SourceAnchor?,
        _ src_: TackInstruction.Register16,
        _ addr_: TackInstruction.RegisterPointer,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        guard imm > 15 || imm < -16 else {
            let addr = corresponding(.p(addr_))
            let src = corresponding(.w(src_))
            return InstructionNode(
                sourceAnchor: sourceAnchor,
                instruction: kSTORE,
                parameters: [
                    src,
                    addr,
                    ParameterNumber(imm),
                ]
            )
        }
        let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
        let addr1 = corresponding(.p(addr_))
        let offset = nextRegister()
        let addr2 = nextRegister()
        let src = corresponding(.w(src_))

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int(imm16 & 0x00ff)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int((imm16 & 0xff00) >> 8)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADD,
                    parameters: [
                        ParameterIdentifier(addr2),
                        ParameterIdentifier(offset),
                        addr1,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kSTORE,
                    parameters: [
                        src,
                        ParameterIdentifier(addr2),
                    ]
                ),
            ]
        )
    }

    func sb(
        _ sourceAnchor: SourceAnchor?,
        _ src_: TackInstruction.Register8,
        _ addr_: TackInstruction.RegisterPointer,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        guard imm > 15 || imm < -16 else {
            let addr = corresponding(.p(addr_))
            let src = corresponding(.b(src_))
            return InstructionNode(
                sourceAnchor: sourceAnchor,
                instruction: kSTORE,
                parameters: [
                    src,
                    addr,
                    ParameterNumber(imm),
                ]
            )
        }
        let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
        let addr1 = corresponding(.p(addr_))
        let offset = nextRegister()
        let addr2 = nextRegister()
        let src = corresponding(.b(src_))

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int(imm16 & 0x00ff)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        ParameterIdentifier(offset),
                        ParameterNumber(Int((imm16 & 0xff00) >> 8)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADD,
                    parameters: [
                        ParameterIdentifier(addr2),
                        ParameterIdentifier(offset),
                        addr1,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kSTORE,
                    parameters: [
                        src,
                        ParameterIdentifier(addr2),
                    ]
                ),
            ]
        )
    }

    func ststr(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.RegisterPointer,
        _ str: String
    ) -> AbstractSyntaxTreeNode? {
        // TODO: Use the offset parameter of the STORE instruction to improve STSTR performance.
        let originalDst = corresponding(.p(dst_))
        let dst = ParameterIdentifier(nextRegister())
        let src = ParameterIdentifier(nextRegister())
        var children: [AbstractSyntaxTreeNode] = [
            InstructionNode(
                sourceAnchor: sourceAnchor,
                instruction: kADDI,
                parameters: [dst, originalDst, ParameterNumber(0)]
            )
        ]
        if str == "" {
            return nil
        }
        for character in str.utf8 {
            let imm16 = UInt16(character)
            let lower = Int(imm16 & 0x00ff)
            let upper = Int((imm16 & 0xff00) >> 8)
            children += [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [src, ParameterNumber(lower)]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [src, ParameterNumber(upper)]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kSTORE,
                    parameters: [src, dst, ParameterNumber(0)]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [dst, dst, ParameterNumber(1)]
                ),
            ]
        }
        return Seq(sourceAnchor: sourceAnchor, children: children)
    }

    func memcpy(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.RegisterPointer,
        _ src_: TackInstruction.RegisterPointer,
        _ numberOfWords: Int
    ) -> AbstractSyntaxTreeNode? {
        // TODO: Use the offset parameter of the STORE instruction to improve MEMCPY performance.
        let originalDst = corresponding(.p(dst_))
        let originalSrc = corresponding(.p(src_))
        switch numberOfWords {
        case 0:
            return Seq(sourceAnchor: sourceAnchor)

        case 1:
            let temp = ParameterIdentifier(nextRegister())
            var children: [AbstractSyntaxTreeNode] = []
            for _ in 0..<numberOfWords {
                children += [
                    InstructionNode(
                        sourceAnchor: sourceAnchor,
                        instruction: kLOAD,
                        parameters: [temp, originalSrc, ParameterNumber(0)]
                    ),
                    InstructionNode(
                        sourceAnchor: sourceAnchor,
                        instruction: kSTORE,
                        parameters: [temp, originalDst, ParameterNumber(0)]
                    ),
                ]
            }
            return Seq(children: children)

        default:
            // TODO: If the number of words to memcpy is large then generate code for a loop instead of this.
            let dst = ParameterIdentifier(nextRegister())
            let src = ParameterIdentifier(nextRegister())
            let temp = ParameterIdentifier(nextRegister())
            var children: [AbstractSyntaxTreeNode] = [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [dst, originalDst, ParameterNumber(0)]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [src, originalSrc, ParameterNumber(0)]
                ),
            ]
            for _ in 0..<numberOfWords {
                children += [
                    InstructionNode(
                        sourceAnchor: sourceAnchor,
                        instruction: kLOAD,
                        parameters: [temp, src, ParameterNumber(0)]
                    ),
                    InstructionNode(
                        sourceAnchor: sourceAnchor,
                        instruction: kSTORE,
                        parameters: [temp, dst, ParameterNumber(0)]
                    ),
                    InstructionNode(
                        sourceAnchor: sourceAnchor,
                        instruction: kADDI,
                        parameters: [dst, dst, ParameterNumber(1)]
                    ),
                    InstructionNode(
                        sourceAnchor: sourceAnchor,
                        instruction: kADDI,
                        parameters: [src, src, ParameterNumber(1)]
                    ),
                ]
            }
            return Seq(sourceAnchor: sourceAnchor, children: children)
        }
    }

    func alloca(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.RegisterPointer,
        _ size: Int
    ) -> AbstractSyntaxTreeNode? {
        Seq(
            sourceAnchor: sourceAnchor,
            children: [
                subip(sourceAnchor, .sp, .sp, size)!,
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        corresponding(.p(dst_)),
                        ParameterIdentifier("sp"),
                        ParameterNumber(0),
                    ]
                ),
            ]
        )
    }

    func free(_ sourceAnchor: SourceAnchor?, _ size: Int) -> AbstractSyntaxTreeNode? {
        addip(sourceAnchor, .sp, .sp, size)
    }

    fileprivate func opWithImm16(
        _ sourceAnchor: SourceAnchor?,
        _ rrr: String,
        _ rri: String,
        _ dst_: TackInstruction.Register16,
        _ left_: TackInstruction.Register16,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        opWithImm(
            sourceAnchor,
            rrr,
            rri,
            .w(dst_),
            .w(left_),
            imm
        )
    }

    fileprivate func opWithImm(
        _ sourceAnchor: SourceAnchor?,
        _ rrr: String,
        _ rri: String,
        _ dst_: TackInstruction.Register,
        _ left_: TackInstruction.Register,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        guard imm > 15 || imm < -16 else {
            let left = corresponding(left_)
            let dst = corresponding(dst_)
            return InstructionNode(
                sourceAnchor: sourceAnchor,
                instruction: rri,
                parameters: [
                    dst,
                    left,
                    ParameterNumber(imm),
                ]
            )
        }
        let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
        let left = corresponding(left_)
        let right = nextRegister()
        let dst = corresponding(dst_)

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        ParameterIdentifier(right),
                        ParameterNumber(Int(imm16 & 0x00ff)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        ParameterIdentifier(right),
                        ParameterNumber(Int((imm16 & 0xff00) >> 8)),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: rrr,
                    parameters: [
                        dst,
                        left,
                        ParameterIdentifier(right),
                    ]
                ),
            ]
        )
    }

    func andiw(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register16,
        _ left_: TackInstruction.Register16,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        opWithImm16(sourceAnchor, kAND, kANDI, dst_, left_, imm)
    }

    func addip(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.RegisterPointer,
        _ left_: TackInstruction.RegisterPointer,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        opWithImm(sourceAnchor, kADD, kADDI, .p(dst_), .p(left_), imm)
    }

    func addiw(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register16,
        _ left_: TackInstruction.Register16,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        opWithImm16(sourceAnchor, kADD, kADDI, dst_, left_, imm)
    }

    func subip(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.RegisterPointer,
        _ left_: TackInstruction.RegisterPointer,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        opWithImm(sourceAnchor, kSUB, kSUBI, .p(dst_), .p(left_), imm)
    }

    func subiw(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register16,
        _ left_: TackInstruction.Register16,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        opWithImm16(sourceAnchor, kSUB, kSUBI, dst_, left_, imm)
    }

    func muliw(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register16,
        _ left_: TackInstruction.Register16,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {

        if imm == 0 {
            _ = corresponding(.w(left_))
            let dst = corresponding(.w(dst_))

            return InstructionNode(
                sourceAnchor: sourceAnchor,
                instruction: kLI,
                parameters: [
                    dst,
                    ParameterNumber(0),
                ]
            )
        } else if imm == 1 {
            let src = corresponding(.w(left_))
            let dst = corresponding(.w(dst_))

            return Seq(
                sourceAnchor: sourceAnchor,
                children: [
                    InstructionNode(
                        sourceAnchor: sourceAnchor,
                        instruction: kADDI,
                        parameters: [
                            dst,
                            src,
                            ParameterNumber(0),
                        ]
                    )
                ]
            )
        } else if imm == -1 {
            let src = corresponding(.w(left_))
            let intermediate = ParameterIdentifier(nextRegister())
            let dst = corresponding(.w(dst_))

            return Seq(
                sourceAnchor: sourceAnchor,
                children: [
                    InstructionNode(
                        sourceAnchor: sourceAnchor,
                        instruction: kNOT,
                        parameters: [
                            intermediate,
                            src,
                        ]
                    ),
                    InstructionNode(
                        sourceAnchor: sourceAnchor,
                        instruction: kADDI,
                        parameters: [
                            dst,
                            intermediate,
                            ParameterNumber(1),
                        ]
                    ),
                ]
            )
        }

        return muliw_pow2(sourceAnchor, dst_, left_, imm)
    }

    fileprivate func muliw_pow2(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register16,
        _ left_: TackInstruction.Register16,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
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
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADD,
                    parameters: [
                        resultStack[resultStack.count - 1],
                        multiplier,
                        multiplier,
                    ]
                )
            ]
            for _ in 1..<exponent {
                children += [
                    InstructionNode(
                        sourceAnchor: sourceAnchor,
                        instruction: kADD,
                        parameters: [
                            resultStack[resultStack.count - 1],
                            resultStack[resultStack.count - 1],
                            resultStack[resultStack.count - 1],
                        ]
                    )
                ]
            }
        }

        var sum: ParameterIdentifier

        if resultStack.count < 2 {
            sum = resultStack.last!
        } else {
            sum = ParameterIdentifier(nextRegister())
            children += [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADD,
                    parameters: [
                        sum,
                        resultStack[0],
                        resultStack[1],
                    ]
                )
            ]
            for component in resultStack[2..<resultStack.count] {
                children += [
                    InstructionNode(
                        sourceAnchor: sourceAnchor,
                        instruction: kADD,
                        parameters: [
                            sum,
                            sum,
                            component,
                        ]
                    )
                ]
            }
        }

        if multiplicand == 1 {
            children += [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADD,
                    parameters: [
                        sum,
                        sum,
                        multiplier,
                    ]
                )
            ]
        }

        if mustNegateAtEnd {
            let t1 = ParameterIdentifier(nextRegister())
            let t2 = ParameterIdentifier(nextRegister())
            children += [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kNOT,
                    parameters: [
                        t1,
                        sum,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        t2,
                        t1,
                        ParameterNumber(1),
                    ]
                ),
            ]
            sum = t2
        }

        registerMap[.w(dst_)] = sum.value

        return Seq(children: children)
    }

    func lio(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.RegisterBoolean,
        _ imm: Bool
    ) -> AbstractSyntaxTreeNode? {
        let dst = corresponding(.o(dst_))
        return InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kLI,
            parameters: [
                dst,
                ParameterNumber(imm ? 1 : 0),
            ]
        )
    }

    func liw(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register16,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        guard imm >= Int8.min && imm <= Int8.max else {
            let imm16: UInt16 = (imm < 0) ? (UInt16(0) &- UInt16(-imm)) : UInt16(imm)
            let dst = corresponding(.w(dst_))
            let lower = Int(imm16 & 0x00ff)
            let upper = Int((imm16 & 0xff00) >> 8)

            return Seq(
                sourceAnchor: sourceAnchor,
                children: [
                    InstructionNode(
                        sourceAnchor: sourceAnchor,
                        instruction: kLI,
                        parameters: [
                            dst,
                            ParameterNumber(lower),
                        ]
                    ),
                    InstructionNode(
                        sourceAnchor: sourceAnchor,
                        instruction: kLUI,
                        parameters: [
                            dst,
                            ParameterNumber(upper),
                        ]
                    ),
                ]
            )
        }
        let dst = corresponding(.w(dst_))
        return InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kLI,
            parameters: [
                dst,
                ParameterNumber(imm),
            ]
        )
    }

    func lip(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.RegisterPointer,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        guard imm > 127 else {
            let dst = corresponding(.p(dst_))
            return InstructionNode(
                sourceAnchor: sourceAnchor,
                instruction: kLI,
                parameters: [
                    dst,
                    ParameterNumber(imm),
                ]
            )
        }
        let imm16 = UInt16(imm)
        let dst = corresponding(.p(dst_))
        let lower = Int(imm16 & 0x00ff)
        let upper = Int((imm16 & 0xff00) >> 8)

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        dst,
                        ParameterNumber(lower),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        dst,
                        ParameterNumber(upper),
                    ]
                ),
            ]
        )
    }

    func liuw(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register16,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        guard imm > 127 else {
            let dst = corresponding(.w(dst_))
            return InstructionNode(
                sourceAnchor: sourceAnchor,
                instruction: kLI,
                parameters: [
                    dst,
                    ParameterNumber(imm),
                ]
            )
        }
        let imm16 = UInt16(imm)
        let dst = corresponding(.w(dst_))
        let lower = Int(imm16 & 0x00ff)
        let upper = Int((imm16 & 0xff00) >> 8)

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        dst,
                        ParameterNumber(lower),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        dst,
                        ParameterNumber(upper),
                    ]
                ),
            ]
        )
    }

    func andw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register16,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        return InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kAND,
            parameters: [
                c, a, b,
            ]
        )
    }

    func orw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register16,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        return InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kOR,
            parameters: [
                c, a, b,
            ]
        )
    }

    func xorw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register16,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        return InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kXOR,
            parameters: [
                c, a, b,
            ]
        )
    }

    func negw(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register16,
        _ src_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let src = corresponding(.w(src_))
        let dst = corresponding(.w(dst_))
        return InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kNOT,
            parameters: [
                dst, src,
            ]
        )
    }

    func addpw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterPointer,
        _ a_: TackInstruction.RegisterPointer,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.p(a_))
        let c = corresponding(.p(c_))
        return InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kADD,
            parameters: [
                c, a, b,
            ]
        )
    }

    func addw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register16,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        return InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kADD,
            parameters: [
                c, a, b,
            ]
        )
    }

    func subw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register16,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.w(c_))
        return InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kSUB,
            parameters: [
                c, a, b,
            ]
        )
    }

    fileprivate var labelMaker = LabelMaker(prefix: ".LL")

    func mulw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register16,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let right = corresponding(.w(b_))
        let left = corresponding(.w(a_))
        let counter = ParameterIdentifier(nextRegister())
        let result = corresponding(.w(c_))
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        result,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        counter,
                        left,
                        ParameterNumber(0),
                    ]
                ),
                LabelDeclaration(identifier: head),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMPI,
                    parameters: [
                        counter,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBEQ,
                    parameters: [
                        ParameterIdentifier(tail)
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADD,
                    parameters: [
                        result,
                        result,
                        right,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kSUBI,
                    parameters: [
                        counter,
                        counter,
                        ParameterNumber(1),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kJMP,
                    parameters: [
                        ParameterIdentifier(head)
                    ]
                ),
                LabelDeclaration(identifier: tail),
            ]
        )
    }

    func divw(
        _ sourceAnchor: SourceAnchor?,
        _ c: TackInstruction.Register16,
        _ a: TackInstruction.Register16,
        _ b: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        divx(sourceAnchor, .w(c), .w(a), .w(b))
    }

    func divb(
        _ sourceAnchor: SourceAnchor?,
        _ c: TackInstruction.Register8,
        _ a: TackInstruction.Register8,
        _ b: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        Seq(children: [
            divx(sourceAnchor, .b(c), .b(a), .b(b)),
            signExtend8(corresponding(.b(c))),
        ])
    }

    func divx(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register,
        _ a_: TackInstruction.Register,
        _ b_: TackInstruction.Register
    ) -> AbstractSyntaxTreeNode {
        // TODO: Maybe division should be a library function instead of always inlining it like this?

        let originalB = corresponding(b_)
        let originalA = corresponding(a_)
        let c = corresponding(c_)
        let b = ParameterIdentifier(nextRegister())
        let a = ParameterIdentifier(nextRegister())
        let negativeNumerator = ParameterIdentifier(
            sourceAnchor: sourceAnchor,
            value: labelMaker.next()
        )
        let negativeDenominator = ParameterIdentifier(
            sourceAnchor: sourceAnchor,
            value: labelMaker.next()
        )
        let negativeBoth = ParameterIdentifier(sourceAnchor: sourceAnchor, value: labelMaker.next())
        let positiveBoth = ParameterIdentifier(sourceAnchor: sourceAnchor, value: labelMaker.next())
        let tail = ParameterIdentifier(sourceAnchor: sourceAnchor, value: labelMaker.next())
        let zero = ParameterNumber(0)
        let one = ParameterNumber(1)
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                // First, copy the operands to some temporaries so the originals are
                // not modified while we do this.
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        a,
                        originalA,
                        zero,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        b,
                        originalB,
                        zero,
                    ]
                ),

                // We have branches for each combination of the operands' signs.
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMPI,
                    parameters: [a, zero]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBLT,
                    parameter: negativeNumerator
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMPI,
                    parameters: [b, zero]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBLT,
                    parameter: negativeDenominator
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kJMP,
                    parameters: [positiveBoth]
                ),

                // If the numerator is negative then negate it to make it positive.
                // Check to see if this is the case where both numerator and
                // denominator are negative and jump to that branch if appropriate.
                // Else, Perform the core unsigned division algorithm.
                // Finally, negate the result and jump to the end.
                LabelDeclaration(negativeNumerator),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kNOT, parameters: [a, a]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [a, a, one]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMPI,
                    parameters: [b, zero]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBLT,
                    parameter: negativeBoth
                ),
                divux_core(sourceAnchor, c, a, b),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kNOT, parameters: [c, c]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [c, c, one]
                ),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kJMP, parameters: [tail]),

                // If the denominator is negative then negate to make it positive.
                // Perform the core unsigned division algorithm.
                // Finally, negate the result and jump to the end.
                LabelDeclaration(negativeDenominator),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kNOT, parameters: [b, b]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [b, b, one]
                ),
                divux_core(sourceAnchor, c, a, b),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kNOT, parameters: [c, c]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [c, c, one]
                ),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kJMP, parameters: [tail]),

                // We've determined that both the nominator and denominator are
                // negative. The numerator has already been negated and we need to
                // negate the denominator too.
                // Perform the core unsigned division algorithm.
                // Unlike the other branches, we do not need to negate the result.
                LabelDeclaration(negativeBoth),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kNOT, parameters: [b, b]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [b, b, one]
                ),
                LabelDeclaration(positiveBoth),
                divux_core(sourceAnchor, c, a, b),

                LabelDeclaration(tail),
            ]
        )
    }

    func divux_core(
        _ sourceAnchor: SourceAnchor?,
        _ c: ParameterIdentifier,
        _ a: ParameterIdentifier,
        _ b: ParameterIdentifier
    ) -> AbstractSyntaxTreeNode {
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        c,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMPI,
                    parameters: [
                        b,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBEQ,
                    parameters: [
                        ParameterIdentifier(tail)
                    ]
                ),
                LabelDeclaration(identifier: head),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMP,
                    parameters: [
                        a,
                        b,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBLTU,
                    parameters: [
                        ParameterIdentifier(tail)
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kSUB,
                    parameters: [
                        a,
                        a,
                        b,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        c,
                        c,
                        ParameterNumber(1),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kJMP,
                    parameters: [
                        ParameterIdentifier(head)
                    ]
                ),
                LabelDeclaration(identifier: tail),
            ]
        )
    }

    func divuw(
        _ sourceAnchor: SourceAnchor?,
        _ c: TackInstruction.Register16,
        _ a: TackInstruction.Register16,
        _ b: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        divux(sourceAnchor, .w(c), .w(a), .w(b))
    }

    func divub(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register8,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        Seq(children: [
            divux(sourceAnchor, .b(c_), .b(a_), .b(b_)),
            signExtend8(corresponding(.b(c_))),
        ])
    }

    func divux(
        _ sourceAnchor: SourceAnchor?,
        _ c: TackInstruction.Register,
        _ a: TackInstruction.Register,
        _ b: TackInstruction.Register
    ) -> AbstractSyntaxTreeNode {
        let right = corresponding(b)
        let left = corresponding(a)
        let tempLeft = ParameterIdentifier(nextRegister())
        let result = corresponding(c)
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        result,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMPI,
                    parameters: [
                        right,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBEQ,
                    parameters: [
                        ParameterIdentifier(tail)
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        tempLeft,
                        left,
                        ParameterNumber(0),
                    ]
                ),
                LabelDeclaration(identifier: head),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMP,
                    parameters: [
                        tempLeft,
                        right,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBLTU,
                    parameters: [
                        ParameterIdentifier(tail)
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kSUB,
                    parameters: [
                        tempLeft,
                        tempLeft,
                        right,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        result,
                        result,
                        ParameterNumber(1),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kJMP,
                    parameters: [
                        ParameterIdentifier(head)
                    ]
                ),
                LabelDeclaration(identifier: tail),
            ]
        )
    }

    func mod16(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register16,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let right = corresponding(.w(b_))
        let left = corresponding(.w(a_))
        let tempLeft = corresponding(.w(c_))
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        tempLeft,
                        left,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMPI,
                    parameters: [
                        right,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBEQ,
                    parameters: [
                        ParameterIdentifier(tail)
                    ]
                ),
                LabelDeclaration(identifier: head),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMP,
                    parameters: [
                        tempLeft,
                        right,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBLTU,
                    parameters: [
                        ParameterIdentifier(tail)
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kSUB,
                    parameters: [
                        tempLeft,
                        tempLeft,
                        right,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kJMP,
                    parameters: [
                        ParameterIdentifier(head)
                    ]
                ),
                LabelDeclaration(identifier: tail),
            ]
        )
    }

    func lslw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register16,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let N = 16
        let b = corresponding(.w(c_))  // TODO: Terrible naming conventions for the local vars here
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

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
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
            ]
        )
    }

    func lsrw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register16,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let N = 16
        let b = corresponding(.w(c_))  // TODO: Terrible naming conventions for the local vars here
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

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
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
            ]
        )
    }

    func eqp(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.RegisterPointer,
        _ b_: TackInstruction.RegisterPointer
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.p(b_))
        let a = corresponding(.p(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(instruction: kCMP, parameters: [a, b]),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
                InstructionNode(instruction: kBEQ, parameter: ll0),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
                LabelDeclaration(ll0),
            ]
        )
    }

    func nep(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.RegisterPointer,
        _ b_: TackInstruction.RegisterPointer
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.p(b_))
        let a = corresponding(.p(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(instruction: kCMP, parameters: [a, b]),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
                InstructionNode(instruction: kBNE, parameter: ll0),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
                LabelDeclaration(ll0),
            ]
        )
    }

    func eqw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(instruction: kCMP, parameters: [a, b]),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
                InstructionNode(instruction: kBEQ, parameter: ll0),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
                LabelDeclaration(ll0),
            ]
        )
    }

    func new(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(instruction: kCMP, parameters: [a, b]),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
                InstructionNode(instruction: kBNE, parameter: ll0),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
                LabelDeclaration(ll0),
            ]
        )
    }

    func ltw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(instruction: kCMP, parameters: [a, b]),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
                InstructionNode(instruction: kBLT, parameter: ll0),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
                LabelDeclaration(ll0),
            ]
        )
    }

    func gew(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(instruction: kCMP, parameters: [a, b]),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
                InstructionNode(instruction: kBLT, parameter: ll0),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
                LabelDeclaration(ll0),
            ]
        )
    }

    func lew(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(instruction: kCMP, parameters: [a, b]),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
                InstructionNode(instruction: kBGT, parameter: ll0),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
                LabelDeclaration(ll0),
            ]
        )
    }

    func gtw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(instruction: kCMP, parameters: [a, b]),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
                InstructionNode(instruction: kBGT, parameter: ll0),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
                LabelDeclaration(ll0),
            ]
        )
    }

    func ltuw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(instruction: kCMP, parameters: [a, b]),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
                InstructionNode(instruction: kBLTU, parameter: ll0),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
                LabelDeclaration(ll0),
            ]
        )
    }

    func geuw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(instruction: kCMP, parameters: [a, b]),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
                InstructionNode(instruction: kBLTU, parameter: ll0),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
                LabelDeclaration(ll0),
            ]
        )
    }

    func leuw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(instruction: kCMP, parameters: [a, b]),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
                InstructionNode(instruction: kBGTU, parameter: ll0),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
                LabelDeclaration(ll0),
            ]
        )
    }

    func gtuw(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register16,
        _ b_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.w(b_))
        let a = corresponding(.w(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(instruction: kCMP, parameters: [a, b]),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(1)]),
                InstructionNode(instruction: kBGTU, parameter: ll0),
                InstructionNode(instruction: kLI, parameters: [c, ParameterNumber(0)]),
                LabelDeclaration(ll0),
            ]
        )
    }

    func li8(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register8,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        // The hardware always sign-extends this immediate value.
        assert(imm >= -128 && imm < 128)
        let dst = corresponding(.b(dst_))
        return InstructionNode(
            sourceAnchor: sourceAnchor,
            instruction: kLI,
            parameters: [
                dst,
                ParameterNumber(imm),
            ]
        )
    }

    func liu8(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register8,
        _ imm: Int
    ) -> AbstractSyntaxTreeNode? {
        // The hardware always sign-extends this immediate value. We may need
        // an extra instruction to circumvent this behavior.
        assert(imm >= 0 && imm < 256)
        let dst = corresponding(.b(dst_))
        guard imm > 127 else {
            return InstructionNode(
                sourceAnchor: sourceAnchor,
                instruction: kLI,
                parameters: [
                    dst,
                    ParameterNumber(imm),
                ]
            )
        }
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        dst,
                        ParameterNumber(imm),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        dst,
                        ParameterNumber(0),
                    ]
                ),
            ]
        )
    }

    func and8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register8,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.b(c_))
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kAND,
                    parameters: [c, a, b]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        c,
                        ParameterNumber(0),
                    ]
                ),
            ]
        )
    }

    func or8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register8,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.b(c_))
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kOR,
                    parameters: [c, a, b]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        c,
                        ParameterNumber(0),
                    ]
                ),
            ]
        )
    }

    func xor8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register8,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.b(c_))
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kXOR,
                    parameters: [c, a, b]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        c,
                        ParameterNumber(0),
                    ]
                ),
            ]
        )
    }

    func neg8(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register8,
        _ src_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let src = corresponding(.b(src_))
        let dst = corresponding(.b(dst_))
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kNOT,
                    parameters: [dst, src]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        dst,
                        ParameterNumber(0),
                    ]
                ),
            ]
        )
    }

    func signExtend8(_ c: Parameter) -> Seq {
        let temp = ParameterIdentifier(nextRegister())
        return Seq(children: [
            InstructionNode(
                instruction: kLI,
                parameters: [
                    temp,
                    ParameterNumber(0x80),
                ]
            ),
            InstructionNode(
                instruction: kLUI,
                parameters: [
                    temp,
                    ParameterNumber(0x00),
                ]
            ),
            InstructionNode(
                instruction: kLUI,
                parameters: [
                    c,
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kXOR,
                parameters: [
                    c,
                    c,
                    temp,
                ]
            ),
            InstructionNode(
                instruction: kSUB,
                parameters: [
                    c,
                    c,
                    temp,
                ]
            ),
        ])
    }

    func add8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register8,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.b(c_))

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADD,
                    parameters: [c, a, b]
                ),
                signExtend8(c),
            ]
        )
    }

    func sub8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register8,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.b(c_))

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kSUB,
                    parameters: [c, a, b]
                ),
                signExtend8(c),
            ]
        )
    }

    func mul8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register8,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        // TODO: Consolidate implementation with the very similar mulw()
        let right = corresponding(.b(b_))
        let left = corresponding(.b(a_))
        let counter = ParameterIdentifier(nextRegister())
        let result = corresponding(.b(c_))
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        result,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        counter,
                        left,
                        ParameterNumber(0),
                    ]
                ),
                LabelDeclaration(identifier: head),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMPI,
                    parameters: [
                        counter,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBEQ,
                    parameters: [
                        ParameterIdentifier(tail)
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADD,
                    parameters: [
                        result,
                        result,
                        right,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kSUBI,
                    parameters: [
                        counter,
                        counter,
                        ParameterNumber(1),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kJMP,
                    parameters: [
                        ParameterIdentifier(head)
                    ]
                ),
                LabelDeclaration(identifier: tail),
                signExtend8(corresponding(.b(c_))),
            ]
        )
    }

    func mod8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register8,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        // TODO: Consolidate implementation with the very similar mod16()
        let right = corresponding(.b(b_))
        let left = corresponding(.b(a_))
        let tempLeft = corresponding(.b(c_))
        let head = labelMaker.next()
        let tail = labelMaker.next()
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        tempLeft,
                        left,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMPI,
                    parameters: [
                        right,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBEQ,
                    parameters: [
                        ParameterIdentifier(tail)
                    ]
                ),
                LabelDeclaration(identifier: head),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kCMP,
                    parameters: [
                        tempLeft,
                        right,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kBLTU,
                    parameters: [
                        ParameterIdentifier(tail)
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kSUB,
                    parameters: [
                        tempLeft,
                        tempLeft,
                        right,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kJMP,
                    parameters: [
                        ParameterIdentifier(head)
                    ]
                ),
                LabelDeclaration(identifier: tail),
                signExtend8(corresponding(.b(c_))),
            ]
        )
    }

    func lsl8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register8,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        // TODO: Consolidate implementation with the very similar lslw()
        let N = 16
        let b = corresponding(.b(c_))  // TODO: Terrible naming conventions for the local vars here
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

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
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
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        corresponding(.b(c_)),
                        ParameterNumber(0),
                    ]
                ),
            ]
        )
    }

    func lsr8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.Register8,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        // TODO: Consolidate implementation with the very similar lsrw()
        let N = 16
        let b = corresponding(.b(c_))  // TODO: Terrible naming conventions for the local vars here
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

        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
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
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        corresponding(.b(c_)),
                        ParameterNumber(0),
                    ]
                ),
            ]
        )
    }

    func eq8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                signExtend8(a),
                signExtend8(b),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(1)]
                ),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kBEQ, parameter: ll0),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(0)]
                ),
                LabelDeclaration(ll0),
            ]
        )
    }

    func ne8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                signExtend8(a),
                signExtend8(b),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(1)]
                ),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kBNE, parameter: ll0),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(0)]
                ),
                LabelDeclaration(ll0),
            ]
        )
    }

    func lt8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                signExtend8(a),
                signExtend8(b),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(1)]
                ),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kBLT, parameter: ll0),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(0)]
                ),
                LabelDeclaration(ll0),
            ]
        )
    }

    func ge8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                signExtend8(a),
                signExtend8(b),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(0)]
                ),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kBLT, parameter: ll0),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(1)]
                ),
                LabelDeclaration(ll0),
            ]
        )
    }

    func le8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                signExtend8(a),
                signExtend8(b),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(0)]
                ),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kBGT, parameter: ll0),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(1)]
                ),
                LabelDeclaration(ll0),
            ]
        )
    }

    func gt8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                signExtend8(a),
                signExtend8(b),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(1)]
                ),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kBGT, parameter: ll0),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(0)]
                ),
                LabelDeclaration(ll0),
            ]
        )
    }

    func ltu8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                signExtend8(a),
                signExtend8(b),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(1)]
                ),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kBLTU, parameter: ll0),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(0)]
                ),
                LabelDeclaration(ll0),
            ]
        )
    }

    func geu8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                signExtend8(a),
                signExtend8(b),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(0)]
                ),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kBLTU, parameter: ll0),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(1)]
                ),
                LabelDeclaration(ll0),
            ]
        )
    }

    func leu8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                signExtend8(a),
                signExtend8(b),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(0)]
                ),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kBGTU, parameter: ll0),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(1)]
                ),
                LabelDeclaration(ll0),
            ]
        )
    }

    func gtu8(
        _ sourceAnchor: SourceAnchor?,
        _ c_: TackInstruction.RegisterBoolean,
        _ a_: TackInstruction.Register8,
        _ b_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        let b = corresponding(.b(b_))
        let a = corresponding(.b(a_))
        let c = corresponding(.o(c_))
        let ll0 = ParameterIdentifier(labelMaker.next())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                signExtend8(a),
                signExtend8(b),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kCMP, parameters: [a, b]),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(1)]
                ),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kBGTU, parameter: ll0),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [c, ParameterNumber(0)]
                ),
                LabelDeclaration(ll0),
            ]
        )
    }

    func movsbw(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register8,
        _ src_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        // Take lower eight-bits of the value in the source register, sign-
        // extend this to sixteen bits, and write the result to the destination
        // register.
        let src = corresponding(.w(src_))
        let dst = corresponding(.b(dst_))
        let temp = ParameterIdentifier(nextRegister())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        dst,
                        src,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        temp,
                        ParameterNumber(0x80),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        temp,
                        ParameterNumber(0x00),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        dst,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kXOR,
                    parameters: [
                        dst,
                        dst,
                        temp,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kSUB,
                    parameters: [
                        dst,
                        dst,
                        temp,
                    ]
                ),
            ]
        )
    }

    func movswb(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register16,
        _ src_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        // Take lower eight-bits of the value in the source register, sign-
        // extend this to sixteen bits, and write the result to the destination
        // register.
        let src = corresponding(.b(src_))
        let dst = corresponding(.w(dst_))
        let temp = ParameterIdentifier(nextRegister())
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        dst,
                        src,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLI,
                    parameters: [
                        temp,
                        ParameterNumber(0x80),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        temp,
                        ParameterNumber(0x00),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        dst,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kXOR,
                    parameters: [
                        dst,
                        dst,
                        temp,
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kSUB,
                    parameters: [
                        dst,
                        dst,
                        temp,
                    ]
                ),
            ]
        )
    }

    func movzwb(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register16,
        _ src_: TackInstruction.Register8
    ) -> AbstractSyntaxTreeNode? {
        // Move an eight-bit register to a sixteen-bit register, zero-extending
        // to fill the upper bits.
        let src = corresponding(.b(src_))
        let dst = corresponding(.w(dst_))
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        dst,
                        src,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        dst,
                        ParameterNumber(0x00),
                    ]
                ),
            ]
        )
    }

    func movzbw(
        _ sourceAnchor: SourceAnchor?,
        _ dst_: TackInstruction.Register8,
        _ src_: TackInstruction.Register16
    ) -> AbstractSyntaxTreeNode? {
        // Move a sixteen-bit register to a eight-bit register, zero-extending
        // to fill the upper bits.
        let src = corresponding(.w(src_))
        let dst = corresponding(.b(dst_))
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        dst,
                        src,
                        ParameterNumber(0),
                    ]
                ),
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kLUI,
                    parameters: [
                        dst,
                        ParameterNumber(0x00),
                    ]
                ),
            ]
        )
    }

    func bitcast(
        _ sourceAnchor: SourceAnchor?,
        _ dst0: TackInstruction.Register,
        _ src0: TackInstruction.Register
    ) -> AbstractSyntaxTreeNode? {
        let src1 = corresponding(src0)
        let dst1 = corresponding(dst0)
        return Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(
                    sourceAnchor: sourceAnchor,
                    instruction: kADDI,
                    parameters: [
                        dst1,
                        src1,
                        ParameterNumber(0),
                    ]
                )
            ]
        )
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

    func syscall(
        _ sourceAnchor: SourceAnchor?,
        _ n_: TackInstruction.RegisterPointer,
        _ ptr_: TackInstruction.RegisterPointer
    ) -> AbstractSyntaxTreeNode? {
        Seq(
            sourceAnchor: sourceAnchor,
            children: [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kNOP),
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kHLT),
            ]
        )
    }
}

private struct LabelMaker {
    public let prefix: String
    private var tempLabelCounter = 0

    public init(prefix: String = ".L") {
        self.prefix = prefix
    }

    public mutating func next() -> String {
        next(prefix: self.prefix)
    }

    public mutating func next(prefix: String) -> String {
        let label = "\(prefix)\(tempLabelCounter)"
        tempLabelCounter += 1
        return label
    }
}
