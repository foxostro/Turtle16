//
//  SnapToTurtle16Compiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import Turtle16SimulatorCore

public class SnapToTurtle16Compiler: SnapASTTransformerBase {
    public let globalEnvironment: GlobalEnvironment
    public internal(set) var registerStack: [String] = []
    var nextRegisterIndex = 0
    let fp = "fp"
    
    func pushRegister(_ identifier: String) {
        registerStack.append(identifier)
    }
    
    func popRegister() -> String {
        assert(!registerStack.isEmpty)
        return registerStack.removeLast()
    }
    
    func nextRegister() -> String {
        let result = "vr\(nextRegisterIndex)"
        nextRegisterIndex += 1
        return result
    }
    
    public init(symbols: SymbolTable, globalEnvironment: GlobalEnvironment) {
        self.globalEnvironment = globalEnvironment
        super.init(symbols)
    }
    
    public override func compile(block node: Block) throws -> AbstractSyntaxTreeNode? {
        let result = try super.compile(block: node) as! Block
        
        if result.children.count < 2 {
            return result.children.first
        }
        
        return Seq(sourceAnchor: node.sourceAnchor, children: result.children)
    }
    
    public override func compile(return node: Return) throws -> AbstractSyntaxTreeNode? {
        assert(node.expression == nil)
        return Seq(sourceAnchor: node.sourceAnchor, children: [
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLEAVE),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kRET)
        ])
    }
    
    public override func compile(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        let sizeOfLocalVariables = node.symbols.highwaterMark
        
        let mangledName = (try TypeContextTypeChecker(symbols: symbols!).check(expression: node.functionType).unwrapFunctionType()).mangledName!
        let labelHead = mangledName
        let labelTail = "__\(mangledName)_tail"
        
        var children: [AbstractSyntaxTreeNode] = []
        
        children += [
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kJMP, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: labelTail)
            ])),
            LabelDeclaration(sourceAnchor: node.sourceAnchor, identifier: labelHead),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kENTER, parameters: ParameterList(parameters: [
                ParameterNumber(value: sizeOfLocalVariables)
            ])),
            node.body,
            LabelDeclaration(sourceAnchor: node.sourceAnchor, identifier: labelTail),
        ]
        
        return try compile(seq: Seq(sourceAnchor: node.sourceAnchor, children: children))
    }
    
    public override func compile(goto node: Goto) throws -> AbstractSyntaxTreeNode? {
        return InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kJMP, parameters: ParameterList(parameters: [ParameterIdentifier(value: node.target)]))
    }
    
    public override func compile(gotoIfFalse node: GotoIfFalse) throws -> AbstractSyntaxTreeNode? {
        return Seq(children: [
            try compile(expr: node.condition),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kCMPI, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: popRegister()),
                ParameterNumber(value: 0)
            ])),
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kBEQ, parameters: ParameterList(parameters: [
                 ParameterIdentifier(value: "foo")
            ]))
        ])
    }
    
    public override func compile(expressionStatement node: Expression) throws -> AbstractSyntaxTreeNode? {
        return try compile(expr: node)
    }
    
    func compile(expr node: Expression) throws -> AbstractSyntaxTreeNode {
        switch node {
        case let literal as Expression.LiteralInt:
            return compile(literalInt: literal)
        case let literal as Expression.LiteralBool:
            return compile(literalBoolean: literal)
        case let id as Expression.Identifier:
            return try compile(identifier: id)
        default:
            throw CompilerError(message: "unimplemented: `\(node)'")
        }
    }
    
    func compile(literalInt node: Expression.LiteralInt) -> AbstractSyntaxTreeNode {
        let dest = nextRegister()
        pushRegister(dest)
        let result = InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLI, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: dest),
            ParameterNumber(value: node.value)
        ]))
        return result
    }
    
    func compile(literalBoolean node: Expression.LiteralBool) -> AbstractSyntaxTreeNode {
        let dest = nextRegister()
        pushRegister(dest)
        let result = InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLI, parameters: ParameterList(parameters: [
            ParameterIdentifier(value: dest),
            ParameterNumber(value: node.value ? 1 : 0)
        ]))
        return result
    }
    
    func compile(identifier node: Expression.Identifier) throws -> AbstractSyntaxTreeNode {
        let resolution = try symbols!.resolveWithStackFrameDepth(sourceAnchor: node.sourceAnchor, identifier: node.identifier)
        let symbol = resolution.0
        assert(globalEnvironment.memoryLayoutStrategy.sizeof(type: symbol.type) <= 1)
        let depth = symbols!.stackFrameIndex - resolution.1
        assert(depth >= 0)
        let addr = computeAddressOfSymbol(sourceAnchor: node.sourceAnchor, symbol: symbol, depth: depth)
        let dest = nextRegister()
        let result = try super.compile(seq: Seq(sourceAnchor: node.sourceAnchor, children: [
            addr,
            InstructionNode(sourceAnchor: node.sourceAnchor, instruction: kLOAD, parameters: ParameterList(parameters: [
                ParameterIdentifier(value: dest),
                ParameterIdentifier(value: popRegister()),
            ]))
        ]))!
        pushRegister(dest)
        return result
    }
    
    func computeAddressOfSymbol(sourceAnchor: SourceAnchor?, symbol: Symbol, depth: Int) -> Seq {
        assert(depth >= 0)
        var children: [AbstractSyntaxTreeNode] = []
        switch symbol.storage {
        case .staticStorage:
            let temp = nextRegister()
            pushRegister(temp)
            children += [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLIU, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: temp),
                    ParameterNumber(value: symbol.offset)
                ]))
            ]
        case .automaticStorage:
            children += [
                computeAddressOfLocalVariable(sourceAnchor: sourceAnchor, offset: symbol.offset, depth: depth)
            ]
        }
        return Seq(sourceAnchor: sourceAnchor, children: children)
    }
    
    func computeAddressOfLocalVariable(sourceAnchor: SourceAnchor?, offset: Int, depth: Int) -> Seq {
        assert(depth >= 0)
        
        var children: [AbstractSyntaxTreeNode] = []
        
        let temp_framePointer: String
        
        if depth == 0 {
            temp_framePointer = fp
        } else {
            temp_framePointer = nextRegister()
            
            children += [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kLOAD, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: temp_framePointer),
                    ParameterIdentifier(value: fp)
                ]))
            ]
            
            // Follow the frame pointer `depth' times.
            for _ in 1..<depth {
                children += [
                    InstructionNode(sourceAnchor: sourceAnchor, instruction: kLOAD, parameters: ParameterList(parameters: [
                        ParameterIdentifier(value: temp_framePointer),
                        ParameterIdentifier(value: temp_framePointer)
                    ]))
                ]
            }
        }
        
        let temp_result = nextRegister()
        
        if offset >= 0 {
            children += [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kSUBI, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: temp_result),
                    ParameterIdentifier(value: temp_framePointer),
                    ParameterNumber(value: offset)
                ]))
            ]
        } else {
            children += [
                InstructionNode(sourceAnchor: sourceAnchor, instruction: kADDI, parameters: ParameterList(parameters: [
                    ParameterIdentifier(value: temp_result),
                    ParameterIdentifier(value: temp_framePointer),
                    ParameterNumber(value: -offset)
                ]))
            ]
        }
        
        pushRegister(temp_result)
        
        return Seq(sourceAnchor: sourceAnchor, children: children)
    }
}
