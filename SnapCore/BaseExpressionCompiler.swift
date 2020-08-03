//
//  BaseExpressionCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class BaseExpressionCompiler: NSObject {
    public let symbols: SymbolTable
    public let labelMaker: LabelMaker
    public let kFramePointerAddressHi = Int(YertleToTurtleMachineCodeCompiler.kFramePointerAddressHi)
    public let kFramePointerAddressLo = Int(YertleToTurtleMachineCodeCompiler.kFramePointerAddressLo)
    
    public init(symbols: SymbolTable, labelMaker: LabelMaker) {
        self.symbols = symbols
        self.labelMaker = labelMaker
    }
    
    public func compile(expression: Expression) throws -> [YertleInstruction] {
        return [] // stub
    }
    
    public func rvalueContext() -> RvalueExpressionCompiler {
        return RvalueExpressionCompiler(symbols: symbols, labelMaker: labelMaker)
    }
    
    public func lvalueContext() -> LvalueExpressionCompiler {
        return LvalueExpressionCompiler(symbols: symbols, labelMaker: labelMaker)
    }
    
    public func unsupportedError(expression: Expression) -> Error {
        return CompilerError(sourceAnchor: expression.sourceAnchor,
                             message: "unsupported expression: \(expression)")
    }
    
    public func loadStaticSymbol(_ symbol: Symbol) -> [YertleInstruction] {
        return loadStaticValue(type: symbol.type, offset: symbol.offset)
    }
    
    public func loadStaticValue(type: SymbolType, offset: Int) -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        switch type.sizeof {
        case 0: break
        case 1: instructions += [.load(offset)]
        case 2: instructions += [.load16(offset)]
        default:
            instructions += [
                .push16(offset),
                .loadIndirectN(type.sizeof)
            ]
        }
        return instructions
    }
    
    public func loadStackSymbol(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        return loadStackValue(type: symbol.type,
                              offset: symbol.offset,
                              depth: depth)
    }
    
    public func loadStackValue(type: SymbolType, offset: Int, depth: Int) -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        instructions += computeAddressOfLocalVariable(offset: offset, depth: depth)
        instructions += indirectLoadValue(type)
        return instructions
    }
    
    public func computeAddressOfLocalVariable(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        return computeAddressOfLocalVariable(offset: symbol.offset, depth: depth)
    }
    
    public func computeAddressOfLocalVariable(offset: Int, depth: Int) -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        
        if offset >= 0 {
            // Push the symbol offset. This is used in the subtraction below.
            instructions += [.push16(offset)]
            
            // Load the frame pointer.
            instructions += [.load16(kFramePointerAddressHi)]
            
            // Follow the frame pointer `depth' times.
            instructions += [YertleInstruction].init(repeating: .loadIndirect16, count: depth)
            
            // Apply the offset to get the final address.
            instructions += [.sub16]
        } else {
            // Push the symbol offset. This is used in the subtraction below.
            instructions += [.push16(-offset)]
            
            // Load the frame pointer.
            instructions += [.load16(kFramePointerAddressHi)]
            
            // Follow the frame pointer `depth' times.
            instructions += [YertleInstruction].init(repeating: .loadIndirect16, count: depth)
            
            // Apply the offset to get the final address.
            instructions += [.add16]
        }
        
        return instructions
    }
    
    public func indirectStoreOfValue(type: SymbolType) -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        let size = type.sizeof
        switch size {
        case 0:  break
        case 1:  instructions += [.storeIndirect]
        case 2:  instructions += [.storeIndirect16]
        default: instructions += [.storeIndirectN(size)]
        }
        return instructions
    }
    
    // Given an address on the stack, load a typed value from that address.
    public func indirectLoadValue(_ type: SymbolType) -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        switch type.sizeof {
        case 0:  break
        case 1:  instructions += [.loadIndirect]
        case 2:  instructions += [.loadIndirect16]
        default: instructions += [.loadIndirectN(type.sizeof)]
        }
        return instructions
    }
    
    // Compute and push the address of the specified symbol.
    public func pushAddressOfSymbol(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        switch symbol.storage {
        case .staticStorage: instructions += [.push16(symbol.offset)]
        case .stackStorage:  instructions += computeAddressOfLocalVariable(symbol, depth)
        }
        return instructions
    }
    
    public func compile(subscript expr: Expression.Subscript) throws -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        
        let resolution = try symbols.resolveWithStackFrameDepth(sourceAnchor: expr.identifier.sourceAnchor, identifier: expr.identifier.identifier)
        let symbol = resolution.0
        let depth = symbols.stackFrameIndex - resolution.1
        
        switch symbol.type {
        case .array(count: _, elementType: let elementType):
            instructions += try arraySubscript(symbol, depth, expr, elementType)
        case .dynamicArray(elementType: let elementType):
            instructions += try dynamicArraySubscript(symbol, depth, expr, elementType)
        default:
            abort()
        }
        
        return instructions
    }
    
    // Compile an array element lookup through the subscript operator.
    public func arraySubscript(_ symbol: Symbol, _ depth: Int, _ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [YertleInstruction] {
        abort() // override in a subclass
    }
    
    // Compile an array element lookup in a dynamic array through the subscript operator.
    public func dynamicArraySubscript(_ symbol: Symbol, _ depth: Int, _ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [YertleInstruction] {
        abort() // override in a subclass
    }
    
    public func arraySubscriptLvalue(_ symbol: Symbol, _ depth: Int, _ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        instructions += pushAddressOfSymbol(symbol, depth)
        instructions += try loadAddressOfArrayElement(expr, elementType)
        instructions += arrayBoundsCheck(symbol, depth)
        return instructions
    }
    
    // Assuming the top of the stack holds an address, verify that the address
    // is within the specified fixed array. If so then leave the address on the
    // stack as it was before this check. Else, panic with an appropriate
    // error message.
    private func arrayBoundsCheck(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        return []
    }
    
    public func dynamicArraySubscriptLvalue(_ symbol: Symbol, _ depth: Int, _ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        instructions += pushAddressOfSymbol(symbol, depth)
        instructions += [.loadIndirect16]
        instructions += try loadAddressOfArrayElement(expr, elementType)
        instructions += dynamicArrayBoundsCheck(symbol, depth)
        return instructions
    }
    
    // Assuming the top of the stack holds an address, verify that the address
    // is within the specified dynamic array. If so then leave the address on
    // the stack as it was before this check. Else, panic with an appropriate
    // error message.
    private func dynamicArrayBoundsCheck(_ symbol: Symbol, _ depth: Int) -> [YertleInstruction] {
        return []
    }
    
    // Given an array address on the stack, determine the address of the array
    // element at an index determined by the expression, and push to the stack.
    public func loadAddressOfArrayElement(_ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [YertleInstruction] {
        var instructions: [YertleInstruction] = []
        
        // Push instructions to compute the subscript index.
        // This must be converted to u16 so we can do math with the address.
        instructions += try rvalueContext().compileAndConvertExpressionForExplicitCast(rexpr: expr.expr, ltype: .u16)
        
        // Multiply the index by the size of an element.
        // Add the element offset to the array address.
        instructions += [
            .push16(elementType.sizeof),
            .mul16,
            .add16
        ]
        
        return instructions
    }
}
