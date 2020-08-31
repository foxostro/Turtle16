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
    public let temporaryStack: CompilerTemporariesStack
    public let temporaryAllocator: CompilerTemporariesAllocator
    
    public let kFramePointerAddressHi = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressHi)
    public let kFramePointerAddressLo = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressLo)
    
    public init(symbols: SymbolTable,
                labelMaker: LabelMaker,
                temporaryStack: CompilerTemporariesStack,
                temporaryAllocator: CompilerTemporariesAllocator) {
        self.symbols = symbols
        self.labelMaker = labelMaker
        self.temporaryStack = temporaryStack
        self.temporaryAllocator = temporaryAllocator
    }
    
    public func compile(expression: Expression) throws -> [CrackleInstruction] {
        return [] // stub
    }
    
    public func rvalueContext() -> RvalueExpressionCompiler {
        return RvalueExpressionCompiler(symbols: symbols,
                                        labelMaker: labelMaker,
                                        temporaryStack: temporaryStack,
                                        temporaryAllocator: temporaryAllocator)
    }
    
    public func lvalueContext() -> LvalueExpressionCompiler {
        return LvalueExpressionCompiler(symbols: symbols,
                                        labelMaker: labelMaker,
                                        temporaryStack: temporaryStack,
                                        temporaryAllocator: temporaryAllocator)
    }
    
    public func unsupportedError(expression: Expression) -> Error {
        return CompilerError(sourceAnchor: expression.sourceAnchor,
                             message: "unsupported expression: \(expression)")
    }
    
    public func loadStaticSymbol(_ symbol: Symbol) -> [CrackleInstruction] {
        return loadStaticValue(type: symbol.type, offset: symbol.offset)
    }
    
    public func loadStaticValue(type: SymbolType, offset: Int) -> [CrackleInstruction] {
        let dst = temporaryAllocator.allocate(size: type.sizeof)
        temporaryStack.push(dst)
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
        var instructions: [CrackleInstruction] = []
        instructions += computeAddressOfLocalVariable(offset: offset, depth: depth)
        let src = temporaryStack.pop()
        let dst = temporaryAllocator.allocate(size: type.sizeof)
        temporaryStack.push(dst)
        src.consume()
        instructions += [.copyWordsIndirectSource(dst.address, src.address, type.sizeof)]
        return instructions
    }
    
    public func computeAddressOfLocalVariable(_ symbol: Symbol, _ depth: Int) -> [CrackleInstruction] {
        return computeAddressOfLocalVariable(offset: symbol.offset, depth: depth)
    }
    
    public func computeAddressOfLocalVariable(offset: Int, depth: Int) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        let temp_framePointer = temporaryAllocator.allocate()
        instructions += [.copyWords(temp_framePointer.address, kFramePointerAddressHi, 2)]
        
        let temp_offset = temporaryAllocator.allocate()
        let temp_result = temporaryAllocator.allocate()
        
        if offset >= 0 {
            instructions += [.storeImmediate16(temp_offset.address, offset)]
            instructions += [.tac_sub16(temp_result.address, temp_framePointer.address, temp_offset.address)]
        } else {
            instructions += [.storeImmediate16(temp_offset.address, -offset)]
            instructions += [.tac_add16(temp_result.address, temp_framePointer.address, temp_offset.address)]
        }
        
        temporaryStack.push(temp_result)
        temp_offset.consume()
        temp_framePointer.consume()
        
        // TODO: need to account for the case where depth>0
        assert(depth == 0)
        
        return instructions
    }
    
    // Compute and push the address of the specified symbol.
    public func computeAddressOfSymbol(_ symbol: Symbol, _ depth: Int) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        switch symbol.storage {
        case .staticStorage:
            let temp = temporaryAllocator.allocate()
            temporaryStack.push(temp)
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
        instructions += arrayBoundsCheck(expr.sourceAnchor, symbol, depth)
        return instructions
    }
    
    // Assuming the top of the stack holds an address, verify that the address
    // is within the specified fixed array. If so then leave the address on the
    // stack as it was before this check. Else, panic with an appropriate
    // error message.
    private func arrayBoundsCheck(_ sourceAnchor: SourceAnchor?, _ symbol: Symbol, _ depth: Int) -> [CrackleInstruction] {
        let label = labelMaker.next()
        var instructions: [CrackleInstruction] = []
        
        let tempAccessAddress = temporaryStack.peek()
        
        instructions += computeAddressOfSymbol(symbol, depth)
        let tempBaseAddress = temporaryStack.pop()
        
        let tempArrayCount = temporaryAllocator.allocate()
        instructions += [.storeImmediate16(tempArrayCount.address, determineArrayCount(symbol.type))]
        
        let tempArrayElementSize = temporaryAllocator.allocate()
        instructions += [.storeImmediate16(tempArrayElementSize.address, determineArrayElementType(symbol.type).sizeof)]
        
        let tempArraySize = temporaryAllocator.allocate()
        instructions += [.tac_mul16(tempArraySize.address, tempArrayCount.address, tempArrayElementSize.address)]
        tempArrayCount.consume()
        tempArrayElementSize.consume()
        
        let tempArrayLimit = temporaryAllocator.allocate()
        instructions += [.tac_add16(tempArrayLimit.address, tempBaseAddress.address, tempArraySize.address)]
        tempBaseAddress.consume()
        tempArraySize.consume()
        
        // Subtract one so we can avoid a limit which might wrap around the
        // bottom of the stack from 0xffff to 0x0000.
        let tempOne = temporaryAllocator.allocate()
        instructions += [.storeImmediate16(tempOne.address, 1)]
        instructions += [.tac_sub16(tempArrayLimit.address, tempArrayLimit.address, tempOne.address)]
        tempOne.consume()
        
        // If (limit-1) < (access address) then the access is unacceptable.
        let tempIsUnacceptable = temporaryAllocator.allocate()
        instructions += [.tac_lt16(tempIsUnacceptable.address, tempArrayLimit.address, tempAccessAddress.address)]
        // Specifically do not conusme tempAccessAddress as we need to leave
        // that in place on the stack when we're done.
        tempArrayLimit.consume()
        
        // If the access is not unacceptable (that is, the access is acceptable)
        // then take the branch to skip the panic.
        instructions += [.tac_jz(label, tempIsUnacceptable.address)]
        tempIsUnacceptable.consume()
        
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
        let sliceAddress = temporaryStack.pop()
        
        // Extract the array base address from the slice structure.
        let baseAddress = temporaryAllocator.allocate()
        temporaryStack.push(baseAddress)
        sliceAddress.consume()
        instructions += [.copyWordsIndirectSource(baseAddress.address, sliceAddress.address, 2)]
        
        instructions += try computeAddressOfArrayElement(expr, elementType)
        
        instructions += dynamicArrayBoundsCheck(expr.sourceAnchor, symbol, depth)
        
        return instructions
    }
    
    // Assuming the top of the stack holds an address, verify that the address
    // is within the specified dynamic array. If so then leave the address on
    // the stack as it was before this check. Else, panic with an appropriate
    // error message.
    private func dynamicArrayBoundsCheck(_ sourceAnchor: SourceAnchor?, _ symbol: Symbol, _ depth: Int) -> [CrackleInstruction] {
        let label = labelMaker.next()
        var instructions: [CrackleInstruction] = []
        
        let tempAccessAddress = temporaryStack.pop()
        
        instructions += computeAddressOfSymbol(symbol, depth)
        let tempSliceAddress = temporaryStack.pop()
        
        // Extract the array base address from the slice structure.
        let tempBaseAddress = temporaryAllocator.allocate()
        instructions += [.copyWordsIndirectSource(tempBaseAddress.address, tempSliceAddress.address, 2)]
        
        // Extract the count from the slice structure too.
        let tempTwo = temporaryAllocator.allocate()
        instructions += [.storeImmediate16(tempTwo.address, 2)]
        tempTwo.consume()
        let tempArrayCountAddress = temporaryAllocator.allocate()
        instructions += [.tac_add16(tempArrayCountAddress.address, tempSliceAddress.address, tempTwo.address)]
        let tempArrayCount = temporaryAllocator.allocate()
        instructions += [.copyWordsIndirectSource(tempArrayCount.address, tempArrayCountAddress.address, 2)]
        tempArrayCountAddress.consume()
        
        let tempArrayElementSize = temporaryAllocator.allocate()
        instructions += [.storeImmediate16(tempArrayElementSize.address, determineArrayElementType(symbol.type).sizeof)]
        let tempArraySize = temporaryAllocator.allocate()
        instructions += [.tac_mul16(tempArraySize.address, tempArrayCount.address, tempArrayElementSize.address)]
        tempArrayElementSize.consume()
        tempArrayCount.consume()
        
        let tempArrayLimit = temporaryAllocator.allocate()
        instructions += [.tac_add16(tempArrayLimit.address, tempBaseAddress.address, tempArraySize.address)]
        tempArraySize.consume()
        tempBaseAddress.consume()
        
        // Subtract one so we can avoid a limit which might wrap around the
        // bottom of the stack from 0xffff to 0x0000.
        let tempOne = temporaryAllocator.allocate()
        instructions += [.storeImmediate16(tempOne.address, 1)]
        tempOne.consume()
        instructions += [.tac_sub16(tempArrayLimit.address, tempArrayLimit.address, tempOne.address)]
        
        // If (limit-1) < (access address) then the access is unacceptable.
        let tempIsUnacceptable = temporaryAllocator.allocate()
        instructions += [.tac_lt16(tempIsUnacceptable.address, tempArrayLimit.address, tempAccessAddress.address)]
        tempArrayLimit.consume()
        
        // If the access is not unacceptable (that is, the access is acceptable)
        // then take the branch to skip the panic.
        instructions += [.tac_jz(label, tempIsUnacceptable.address)]
        tempIsUnacceptable.consume()
        
        instructions += panicOutOfBoundsError(sourceAnchor: sourceAnchor)
        instructions += [.label(label)]
        
        // Specifically do not consume tempAccessAddress as we need to leave
        // that in place on the stack when we're done.
        
        temporaryStack.push(tempAccessAddress)
        
        return instructions
    }
    
    // Given an array address on the compiler temporaries stack, determine the
    // address of the array element at an index determined by the expression,
    // and push to the stack.
    public func computeAddressOfArrayElement(_ expr: Expression.Subscript, _ elementType: SymbolType) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        // Assume that the temporary which holds the array base address is on
        // top of the compiler temporaries stack.
        let baseAddress = temporaryStack.pop()
        
        // Compute the array subscript index.
        // This must be converted to u16 so we can do math with the address.
        instructions += try rvalueContext().compileAndConvertExpressionForExplicitCast(rexpr: expr.expr, ltype: .u16)
        let subscriptIndex = temporaryStack.pop()
        
        let elementSize = temporaryAllocator.allocate()
        temporaryStack.push(elementSize)
        instructions += [.storeImmediate16(elementSize.address, elementType.sizeof)]
        
        let accessOffset = temporaryAllocator.allocate()
        temporaryStack.push(accessOffset)
        elementSize.consume()
        subscriptIndex.consume()
        instructions += [.tac_mul16(accessOffset.address, subscriptIndex.address, elementSize.address)]
        
        let accessAddress = temporaryAllocator.allocate()
        temporaryStack.push(accessAddress)
        accessOffset.consume()
        baseAddress.consume()
        instructions += [.tac_add16(accessAddress.address, baseAddress.address, accessOffset.address)]
        
        // At this point, the temporary which holds the address of the array
        // access is on top of the compiler temporaries stack.
        
        return instructions
    }
}
