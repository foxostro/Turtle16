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
    
    let kFramePointerAddressHi = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressHi)
    let kFramePointerAddressLo = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressLo)
    let kStackPointerAddress: Int = Int(CrackleToTurtleMachineCodeCompiler.kStackPointerAddressHi)
    
    let kSliceBaseAddressOffset = 0
    let kSliceBaseAddressSize = 2
    let kSliceCountOffset = 2
    let kSliceCountSize = 2
    let kSliceSize = 4 // kSliceBaseAddressSize + kSliceCountSize
    
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
        instructions += [.copyWordsIndirectSource(dst.address, src.address, type.sizeof)]
        src.consume()
        temporaryStack.push(dst)
        return instructions
    }
    
    public func computeAddressOfLocalVariable(_ symbol: Symbol, _ depth: Int) -> [CrackleInstruction] {
        return computeAddressOfLocalVariable(offset: symbol.offset, depth: depth)
    }
    
    public func computeAddressOfLocalVariable(offset: Int, depth: Int) -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        let temp_framePointer = temporaryAllocator.allocate()
        instructions += [.copyWords(temp_framePointer.address, kFramePointerAddressHi, 2)]
        
        // Follow the frame pointer `depth' times.
        for _ in 0..<depth {
            instructions += [
                .copyWordsIndirectSource(temp_framePointer.address, temp_framePointer.address, 2)
            ]
        }
        
        let temp_result = temporaryAllocator.allocate()
        
        if offset >= 0 {
            instructions += [.subi16(temp_result.address, temp_framePointer.address, offset)]
        } else {
            instructions += [.addi16(temp_result.address, temp_framePointer.address, -offset)]
        }
        
        temporaryStack.push(temp_result)
        temp_framePointer.consume()
        
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
        case .constDynamicArray(elementType: let elementType),
             .dynamicArray(elementType: let elementType):
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
        instructions += [.mul16(tempArraySize.address, tempArrayCount.address, tempArrayElementSize.address)] // TODO: a MULI16 instruction would be useful here.
        tempArrayCount.consume()
        tempArrayElementSize.consume()
        
        let tempArrayLimit = temporaryAllocator.allocate()
        instructions += [.add16(tempArrayLimit.address, tempBaseAddress.address, tempArraySize.address)]
        tempBaseAddress.consume()
        tempArraySize.consume()
        
        // Subtract one so we can avoid a limit which might wrap around the
        // bottom of the stack from 0xffff to 0x0000.
        instructions += [.subi16(tempArrayLimit.address, tempArrayLimit.address, 1)]
        
        // If (limit-1) < (access address) then the access is unacceptable.
        let tempIsUnacceptable = temporaryAllocator.allocate()
        instructions += [.lt16(tempIsUnacceptable.address, tempArrayLimit.address, tempAccessAddress.address)]
        // Specifically do not conusme tempAccessAddress as we need to leave
        // that in place on the stack when we're done.
        tempArrayLimit.consume()
        
        // If the access is not unacceptable (that is, the access is acceptable)
        // then take the branch to skip the panic.
        instructions += [.jz(label, tempIsUnacceptable.address)]
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
        let arr: [Int] = message.utf8.map({Int($0)})
        let n = arr.count
        
        // Allocate space on the stack for `n' characters and an array slice.
        instructions += [.subi16(kStackPointerAddress, kStackPointerAddress, n+kSliceSize)]
        
        // Copy the string onto the stack.
        let tempDstAddress = temporaryAllocator.allocate()
        let tempCharacter = temporaryAllocator.allocate()
        instructions += [
            .addi16(tempDstAddress.address, kStackPointerAddress, kSliceSize)
        ]
        for i in 0..<n {
            instructions += [
                .storeImmediate(tempCharacter.address, arr[i]),
                .copyWordsIndirectDestination(tempDstAddress.address, tempCharacter.address, 1)
            ]
            if i != n-1 {
                instructions += [
                    .addi16(tempDstAddress.address, tempDstAddress.address, 1)
                ]
            }
        }
        tempCharacter.consume()
        
        // Form an array slice on the top of the stack.
        let tempArrayBaseAddress = temporaryAllocator.allocate()
        let tempCount = temporaryAllocator.allocate()
        assert(kSliceBaseAddressOffset == 0)
        assert(kSliceBaseAddressSize == 2)
        instructions += [
            .addi16(tempArrayBaseAddress.address, kStackPointerAddress, kSliceSize),
            .copyWordsIndirectDestination(kStackPointerAddress, tempArrayBaseAddress.address, kSliceBaseAddressSize),
            
            .addi16(tempDstAddress.address, kStackPointerAddress, kSliceCountOffset),
            .storeImmediate16(tempCount.address, n),
            .copyWordsIndirectDestination(tempDstAddress.address, tempCount.address, kSliceCountSize),
        ]
        tempCount.consume()
        tempArrayBaseAddress.consume()
        tempDstAddress.consume()
        
        // Jump to the panic routine.
        instructions += [
            .jalr("panic")
        ]
        
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
        case .array(count: _, let elementType),
             .constDynamicArray(elementType: let elementType),
             .dynamicArray(elementType: let elementType):
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
        instructions += [.copyWordsIndirectSource(baseAddress.address, sliceAddress.address, 2)]
        sliceAddress.consume()
        
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
        let tempArrayCountAddress = temporaryAllocator.allocate()
        instructions += [.add16(tempArrayCountAddress.address, tempSliceAddress.address, tempTwo.address)]
        tempTwo.consume()
        let tempArrayCount = temporaryAllocator.allocate()
        instructions += [.copyWordsIndirectSource(tempArrayCount.address, tempArrayCountAddress.address, 2)]
        tempArrayCountAddress.consume()
        
        let tempArrayElementSize = temporaryAllocator.allocate()
        instructions += [.storeImmediate16(tempArrayElementSize.address, determineArrayElementType(symbol.type).sizeof)]
        let tempArraySize = temporaryAllocator.allocate()
        instructions += [.mul16(tempArraySize.address, tempArrayCount.address, tempArrayElementSize.address)]
        tempArrayElementSize.consume()
        tempArrayCount.consume()
        
        let tempArrayLimit = temporaryAllocator.allocate()
        instructions += [.add16(tempArrayLimit.address, tempBaseAddress.address, tempArraySize.address)]
        tempArraySize.consume()
        tempBaseAddress.consume()
        
        // Subtract one so we can avoid a limit which might wrap around the
        // bottom of the stack from 0xffff to 0x0000.
        instructions += [.subi16(tempArrayLimit.address, tempArrayLimit.address, 1)]
        
        // If (limit-1) < (access address) then the access is unacceptable.
        let tempIsUnacceptable = temporaryAllocator.allocate()
        instructions += [.lt16(tempIsUnacceptable.address, tempArrayLimit.address, tempAccessAddress.address)]
        tempArrayLimit.consume()
        
        // If the access is not unacceptable (that is, the access is acceptable)
        // then take the branch to skip the panic.
        instructions += [.jz(label, tempIsUnacceptable.address)]
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
        instructions += [.storeImmediate16(elementSize.address, elementType.sizeof)]
        
        let accessOffset = temporaryAllocator.allocate()
        instructions += [.mul16(accessOffset.address, subscriptIndex.address, elementSize.address)]
        elementSize.consume()
        subscriptIndex.consume()
        
        let accessAddress = temporaryAllocator.allocate()
        instructions += [.add16(accessAddress.address, baseAddress.address, accessOffset.address)]
        accessOffset.consume()
        baseAddress.consume()
        temporaryStack.push(accessAddress)
        
        // At this point, the temporary which holds the address of the array
        // access is on top of the compiler temporaries stack.
        
        return instructions
    }
}
