//
//  BaseExpressionCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/28/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

public class BaseExpressionCompiler: NSObject {
    public let symbols: SymbolTable
    public let labelMaker: LabelMaker
    public let temporaries: CompilerTemporaries
    public let kFramePointerAddressHi = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressHi)
    public let kFramePointerAddressLo = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressLo)
    
    public init(symbols: SymbolTable, labelMaker: LabelMaker, temporaries: CompilerTemporaries) {
        self.symbols = symbols
        self.labelMaker = labelMaker
        self.temporaries = temporaries
    }
    
    public func compile(expression: Expression) throws -> [CrackleInstruction] {
        return [] // stub
    }
    
    public func rvalueContext() -> RvalueExpressionCompiler {
        return RvalueExpressionCompiler(symbols: symbols, labelMaker: labelMaker, temporaries: temporaries)
    }
    
    public func lvalueContext() -> LvalueExpressionCompiler {
        return LvalueExpressionCompiler(symbols: symbols, labelMaker: labelMaker, temporaries: temporaries)
    }
    
    public func unsupportedError(expression: Expression) -> Error {
        return CompilerError(sourceAnchor: expression.sourceAnchor,
                             message: "unsupported expression: \(expression)")
    }
    
    public func loadStaticSymbol(_ symbol: Symbol) -> [CrackleInstruction] {
        return loadStaticValue(type: symbol.type, offset: symbol.offset)
    }
    
    public func loadStaticValue(type: SymbolType, offset: Int) -> [CrackleInstruction] {
        let dst = temporaries.allocate()
        temporaries.push(dst)
        var instructions: [CrackleInstruction] = []
        instructions += [.copyWords(dst.address, offset, type.sizeof)]
        return instructions
    }
    
    public func loadStackSymbol(_ symbol: Symbol, _ depth: Int) -> [CrackleInstruction] {
        return loadStackValue(type: symbol.type,
                              offset: symbol.offset,
                              depth: depth)
    }
    
    public func loadStackValue(type: SymbolType, offset: Int, depth: Int) -> [CrackleInstruction] {
        guard type.sizeof <= 2 else {
            abort() // TODO: how do we handle values which are too large to fit into a temporary? fall back to the stack?
        }
        var instructions: [CrackleInstruction] = []
        instructions += computeAddressOfLocalVariable(offset: offset, depth: depth)
        let src = temporaries.pop()
        let dst = temporaries.allocate()
        temporaries.push(dst)
        src.consume()
        instructions += [.copyWordsIndirectSource(dst.address, src.address, type.sizeof)]
        return instructions
    }
    
    public func computeAddressOfLocalVariable(_ symbol: Symbol, _ depth: Int) -> [CrackleInstruction] {
        return computeAddressOfLocalVariable(offset: symbol.offset, depth: depth)
    }
    
    public func computeAddressOfLocalVariable(offset: Int, depth: Int) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        let temp_framePointer = temporaries.allocate()
        instructions += [.copyWords(temp_framePointer.address, kFramePointerAddressHi, 2)]
        
        let temp_offset = temporaries.allocate()
        instructions += [.storeImmediate16(temp_offset.address, offset)]
        
        let temp_result = temporaries.allocate()
        temporaries.push(temp_result)
        temp_offset.consume()
        temp_framePointer.consume()
        instructions += [.tac_sub16(temp_result.address, temp_framePointer.address, temp_offset.address)]
        
        // TODO: need to account for the case where offset<0
        // TODO: need to account for the case where depth>0
        
        return instructions
    }
    
    public func indirectStoreOfValue(type: SymbolType) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
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
    public func indirectLoadValue(_ type: SymbolType) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        switch type.sizeof {
        case 0:  break
        case 1:  instructions += [.loadIndirect]
        case 2:  instructions += [.loadIndirect16]
        default: instructions += [.loadIndirectN(type.sizeof)]
        }
        return instructions
    }
    
    // Compute and push the address of the specified symbol.
    public func computeAddressOfSymbol(_ symbol: Symbol, _ depth: Int) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        switch symbol.storage {
        case .staticStorage:
            let temp = temporaries.allocate()
            temporaries.push(temp)
            instructions += [.storeImmediate16(temp.address, symbol.offset)]
        case .stackStorage:  instructions += computeAddressOfLocalVariable(symbol, depth)
        }
        return instructions
    }
    
    public func compile(subscript expr: Expression.Subscript) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
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
    public func arraySubscript(_ symbol: Symbol, _ depth: Int, _ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [CrackleInstruction] {
        abort() // override in a subclass
    }
    
    // Compile an array element lookup in a dynamic array through the subscript operator.
    public func dynamicArraySubscript(_ symbol: Symbol, _ depth: Int, _ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [CrackleInstruction] {
        abort() // override in a subclass
    }
    
    public func arraySubscriptLvalue(_ symbol: Symbol, _ depth: Int, _ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        instructions += computeAddressOfSymbol(symbol, depth)
        instructions += try computeAddressOfArrayElement(expr, elementType)
//        instructions += arrayBoundsCheck(expr.sourceAnchor, symbol, depth)
        return instructions
    }
    
    // Assuming the top of the stack holds an address, verify that the address
    // is within the specified fixed array. If so then leave the address on the
    // stack as it was before this check. Else, panic with an appropriate
    // error message.
    private func arrayBoundsCheck(_ sourceAnchor: SourceAnchor?, _ symbol: Symbol, _ depth: Int) -> [CrackleInstruction] {
        let label = labelMaker.next()
        var instructions: [CrackleInstruction] = []
        instructions += [
            // Duplicate the address of the access for the comparison, below.
            .dup16,
        ]
        instructions += computeAddressOfSymbol(symbol, depth)
        instructions += [
            // Indented four times to indicate that the stack holds the two
            // addresses pushed above. Each change in level of indent indicates
            // a change in stack depth of one word.
                            .push16(determineArrayCount(symbol.type)),
                                    .push16(determineArrayElementType(symbol.type).sizeof),
                                            .mul16,
                                    .add16,
                            // The 16-bit array limit is now on the top of the stack.
                            // Subtract one element so we can avoid a limit which
                            // might wrap around the bottom of the stack from
                            // 0xffff to 0x0000.
                            .push16(determineArrayElementType(symbol.type).sizeof),
                                    .sub16,
                            .push16(0),
                                    .sub16,
                            // If (limit-1) < (access address) then the access
                            // is unacceptable.
                            .lt16,
                .push(0),
                    .je(label)
            // At end of list, relative change in stack depth is zero.
            // The address of access is still on the top.
        ]
        instructions += panicOutOfBoundsError(sourceAnchor: sourceAnchor)
        instructions += [.label(label)]
        return instructions
    }
    
    private func panicOutOfBoundsError(sourceAnchor: SourceAnchor?) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        var message = "array access is out of bounds"
        if let sourceAnchor = sourceAnchor {
            message += ": `\(sourceAnchor.text)'"
            if let lineNumbers = sourceAnchor.lineNumbers {
                message += " on line \(lineNumbers.lowerBound)"
            }
        }
        let arr: [Int] = message.utf8.reversed().map({Int($0)})
        let n = arr.count
        for c in arr {
            instructions += [.push(c)]
        }
        instructions += [
            .push16(n),
            .push16(4),
            .pushsp,
            .add16
        ]
        instructions += [.jalr("panic")]
        return instructions
    }
    
    private func determineArrayCount(_ type: SymbolType) -> Int {
        let count: Int
        switch type {
        case .array(count: let n, elementType: _):
            count = n!
        default:
            abort()
        }
        return count
    }
    
    private func determineArrayElementType(_ type: SymbolType) -> SymbolType {
        let result: SymbolType
        switch type {
        case .array(count: _, let elementType):
            result = elementType
        case .dynamicArray(elementType: let elementType):
            result = elementType
        default:
            abort()
        }
        return result
    }
    
    public func dynamicArraySubscriptLvalue(_ symbol: Symbol, _ depth: Int, _ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        instructions += computeAddressOfSymbol(symbol, depth)
        let sliceAddress = temporaries.pop()
        
        // Extract the array base address from the slice structure.
        let baseAddress = temporaries.allocate()
        temporaries.push(baseAddress)
        sliceAddress.consume()
        instructions += [.copyWordsIndirectSource(baseAddress.address, sliceAddress.address, 2)]
        
        instructions += try computeAddressOfArrayElement(expr, elementType)
        
//        instructions += dynamicArrayBoundsCheck(expr.sourceAnchor, symbol, depth)
        return instructions
    }
    
    // Assuming the top of the stack holds an address, verify that the address
    // is within the specified dynamic array. If so then leave the address on
    // the stack as it was before this check. Else, panic with an appropriate
    // error message.
    private func dynamicArrayBoundsCheck(_ sourceAnchor: SourceAnchor?, _ symbol: Symbol, _ depth: Int) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        let label = labelMaker.next()
        instructions += [
            // Duplicate the address of the access for the comparison, below.
            .dup16
        ]
        instructions += computeAddressOfSymbol(symbol, depth)
        instructions += [
            // Indented to indicate stack depth. Each change in level of indent
            // indicates a change in stack depth of one word.
                            // Load the array count from memory.
                            .push16(2),
                                    .add16,
                            .loadIndirect16,
                                    // Multiply the count by the size of an individual element to get
                                    // the total array size.
                                    .push16(determineArrayElementType(symbol.type).sizeof),
                                    .mul16,
            ]
        instructions +=             computeAddressOfSymbol(symbol, depth)
        instructions += [
                                    // Load the base address
                                    .loadIndirect16,
                                    // Add the base pointer to the array length
                                    // to get the address just past the end of
                                    // the array.
                                    .add16,
                            // The 16-bit array limit is now on the top of the stack.
                            // Subtract one element so we can avoid a limit which
                            // might wrap around the bottom of the stack from
                            // 0xffff to 0x0000.
                            .push16(determineArrayElementType(symbol.type).sizeof),
                                    .sub16,
                            .push16(0),
                                    .sub16,
                            // If (limit-1) < (access address) then the access
                            // is unacceptable.
                            .lt16,
                .push(0),
                    .je(label)
            // At end of list, relative change in stack depth is zero.
            // The address of access is still on the top.
        ]
        instructions += panicOutOfBoundsError(sourceAnchor: sourceAnchor)
        instructions += [
            .label(label)
        ]
        return instructions
    }
    
    // Given an array address on the compiler temporaries stack, determine the
    // address of the array element at an index determined by the expression,
    // and push to the stack.
    public func computeAddressOfArrayElement(_ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        // Assume that the temporary which holds the array base address is on
        // top of the compiler temporaries stack.
        let baseAddress = temporaries.pop()
        
        // Compute the array subscript index.
        // This must be converted to u16 so we can do math with the address.
        instructions += try rvalueContext().compileAndConvertExpressionForExplicitCast(rexpr: expr.expr, ltype: .u16)
        let subscriptIndex = temporaries.pop()
        
        let elementSize = temporaries.allocate()
        temporaries.push(elementSize)
        instructions += [.storeImmediate16(elementSize.address, elementType.sizeof)]
        
        let accessOffset = temporaries.allocate()
        temporaries.push(accessOffset)
        elementSize.consume()
        subscriptIndex.consume()
        instructions += [.tac_mul16(accessOffset.address, subscriptIndex.address, elementSize.address)]
        
        let accessAddress = temporaries.allocate()
        temporaries.push(accessAddress)
        accessOffset.consume()
        baseAddress.consume()
        instructions += [.tac_add16(accessAddress.address, baseAddress.address, accessOffset.address)]
        
        // At this point, the temporary which holds the address of the array
        // access is on top of the compiler temporaries stack.
        
        return instructions
    }
}
