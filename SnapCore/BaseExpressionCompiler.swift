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
        
        let symbolType = try rvalueContext().typeChecker.check(expression: expr.subscriptable)
        
        switch symbolType {
        case .array:
            let argumentType = try rvalueContext().typeChecker.check(expression: expr.argument)
            if argumentType.isArithmeticType {
                instructions += try arraySubscript(expr)
            } else {
                switch argumentType {
                case .structType, .constStructType:
                    instructions += try arraySlice(expr)
                default:
                    abort()
                }
            }
        case .constDynamicArray, .dynamicArray:
            let argumentType = try rvalueContext().typeChecker.check(expression: expr.argument)
            if argumentType.isArithmeticType {
                instructions += try dynamicArraySubscript(expr)
            } else {
                switch argumentType {
                case .structType, .constStructType:
                    instructions += try dynamicArraySlice(expr)
                default:
                    abort()
                }
            }
        default:
            abort()
        }
        
        return instructions
    }
    
    private func arraySlice(_ expr: Expression.Subscript) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        guard let symbolType = try lvalueContext().typeChecker.check(expression: expr.subscriptable) else {
            throw CompilerError(sourceAnchor: expr.subscriptable.sourceAnchor, message: "lvalue required in array slice")
        }
        
        let tempSlice = temporaryAllocator.allocate(size: kSliceSize)
        
        let kRangeBeginOffset = 0
        let kRangeLimitOffset = SymbolType.u16.sizeof
        
        // Evaluate the range expression first.
        instructions += try compile(expression: expr.argument)
        let tempRangeStruct = temporaryStack.pop()
        
        let tempArrayCount = temporaryAllocator.allocate()
        let tempIsUnacceptable = temporaryAllocator.allocate()
        
        // Check the range begin index to make sure it's in bounds, else panic.
        let labelRangeBeginIsValid = labelMaker.next()
        instructions += [
            .storeImmediate16(tempArrayCount.address, symbolType.arrayCount!),
            .ge16(tempIsUnacceptable.address, tempRangeStruct.address + kRangeBeginOffset, tempArrayCount.address),
            .jz(labelRangeBeginIsValid, tempIsUnacceptable.address)
        ]
        instructions += try panicOutOfBoundsError(sourceAnchor: expr.sourceAnchor)
        instructions += [
            .label(labelRangeBeginIsValid)
        ]
        
        // Check the range limit index to make sure it's in bounds, else panic.
        let labelRangeLimitIsValid = labelMaker.next()
        instructions += [
            .gt16(tempIsUnacceptable.address, tempRangeStruct.address + kRangeLimitOffset, tempArrayCount.address),
            .jz(labelRangeLimitIsValid, tempIsUnacceptable.address)
        ]
        instructions += try panicOutOfBoundsError(sourceAnchor: expr.sourceAnchor)
        instructions += [
            .label(labelRangeLimitIsValid)
        ]
        
        tempIsUnacceptable.consume()
        tempArrayCount.consume()
        
        // Compute the array slice count from the range value.
        instructions += [
            .sub16(tempSlice.address + kSliceCountOffset,
                   tempRangeStruct.address + kRangeLimitOffset,
                   tempRangeStruct.address + kRangeBeginOffset)
        ]
        
        // Compute the base address of the array slice. This is an offset from
        // the original array's base address.
        instructions += try lvalueContext().compile(expression: expr.subscriptable)
        let tempArrayBaseAddress = temporaryStack.pop()
        instructions += [
            .muli16(tempSlice.address + kSliceBaseAddressOffset,
                    tempRangeStruct.address + kRangeBeginOffset,
                    symbolType.arrayElementType.sizeof),
            .add16(tempSlice.address + kSliceBaseAddressOffset,
                   tempSlice.address + kSliceBaseAddressOffset,
                   tempArrayBaseAddress.address)
        ]
        tempArrayBaseAddress.consume()
        
        tempRangeStruct.consume()
        
        // Leave the slice value on the stack on leaving this function.
        temporaryStack.push(tempSlice)
        
        return instructions
    }
    
    // Compile an array element lookup through the subscript operator.
    public func arraySubscript(_ expr: Expression.Subscript) throws -> [CrackleInstruction] {
        abort() // override in a subclass
    }
    
    // Compile an array element lookup in a dynamic array through the subscript operator.
    public func dynamicArraySubscript(_ expr: Expression.Subscript) throws -> [CrackleInstruction] {
        abort() // override in a subclass
    }
    
    private func dynamicArraySlice(_ expr: Expression.Subscript) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        guard let symbolType = try lvalueContext().typeChecker.check(expression: expr.subscriptable) else {
            throw CompilerError(sourceAnchor: expr.subscriptable.sourceAnchor, message: "lvalue required in array slice")
        }
        
        // Get the address of the dynamic array symbol.
        instructions += try lvalueContext().compile(expression: expr.subscriptable)
        let tempDynamicArrayAddress = temporaryStack.pop()
        
        // Evaluate the range expression to get the range value.
        let kRangeBeginOffset = 0
        let kRangeLimitOffset = SymbolType.u16.sizeof
        instructions += try compile(expression: expr.argument)
        let tempRangeStruct = temporaryStack.pop()
        
        // Extract the array count from the dynamic array structure.
        let tempArrayCount = temporaryAllocator.allocate()
        instructions += [
            .copyWords(tempArrayCount.address, tempDynamicArrayAddress.address, kSliceSize),
            .addi16(tempArrayCount.address, tempArrayCount.address, kSliceCountOffset),
            .copyWordsIndirectSource(tempArrayCount.address, tempArrayCount.address, kSliceSize)
        ]
            
        // Check the range begin index to make sure it's in bounds, else panic.
        let tempIsUnacceptable = temporaryAllocator.allocate()
        let labelRangeBeginIsValid = labelMaker.next()
        instructions += [
            .ge16(tempIsUnacceptable.address,
                  tempRangeStruct.address + kRangeBeginOffset,
                  tempArrayCount.address),
            .jz(labelRangeBeginIsValid, tempIsUnacceptable.address)
        ]
        instructions += try panicOutOfBoundsError(sourceAnchor: expr.sourceAnchor)
        instructions += [
            .label(labelRangeBeginIsValid)
        ]
        
        // Check the range limit index to make sure it's in bounds, else panic.
        let labelRangeLimitIsValid = labelMaker.next()
        instructions += [
            .gt16(tempIsUnacceptable.address, tempRangeStruct.address + kRangeLimitOffset, tempArrayCount.address),
            .jz(labelRangeLimitIsValid, tempIsUnacceptable.address)
        ]
        instructions += try panicOutOfBoundsError(sourceAnchor: expr.sourceAnchor)
        instructions += [
            .label(labelRangeLimitIsValid)
        ]
        
        tempIsUnacceptable.consume()
        tempArrayCount.consume()
        
        let tempSlice = temporaryAllocator.allocate(size: kSliceSize)
        
        // Compute the array slice count from the range value.
        instructions += [
            .sub16(tempSlice.address + kSliceCountOffset,
                   tempRangeStruct.address + kRangeLimitOffset,
                   tempRangeStruct.address + kRangeBeginOffset)
        ]
        
        // Compute the base address of the array slice.
        let tempArrayBaseAddress = temporaryAllocator.allocate()
        instructions += [
            .copyWordsIndirectSource(tempArrayBaseAddress.address,
                                     tempDynamicArrayAddress.address,
                                     SymbolType.u16.sizeof),
            .muli16(tempSlice.address + kSliceBaseAddressOffset,
                    tempRangeStruct.address + kRangeBeginOffset,
                    symbolType.arrayElementType.sizeof),
            .add16(tempSlice.address + kSliceBaseAddressOffset,
                   tempSlice.address + kSliceBaseAddressOffset,
                   tempArrayBaseAddress.address)
        ]
        tempArrayBaseAddress.consume()
        
        tempRangeStruct.consume()
        tempDynamicArrayAddress.consume()
        
        // Leave the slice value on the stack on leaving this function.
        temporaryStack.push(tempSlice)
        
        return instructions
    }
    
    public func arraySubscriptLvalue(_ expr: Expression.Subscript) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        let context = lvalueContext()
        guard let symbolType = try context.typeChecker.check(expression: expr.subscriptable) else {
            throw CompilerError(sourceAnchor: expr.subscriptable.sourceAnchor, message: "lvalue required in array subscript")
        }
        let elementType = symbolType.arrayElementType
        
        instructions += try context.compile(expression: expr.subscriptable)
        instructions += try computeAddressOfArrayElement(expr, elementType)
        instructions += try arrayBoundsCheck(expr)
        return instructions
    }
    
    // Assuming the top of the stack holds an address, verify that the address
    // is within the specified fixed array. If so then leave the address on the
    // stack as it was before this check. Else, panic with an appropriate
    // error message.
    private func arrayBoundsCheck(_ expr: Expression.Subscript) throws -> [CrackleInstruction] {
        let label = labelMaker.next()
        var instructions: [CrackleInstruction] = []
        
        let context = lvalueContext()
        guard let symbolType = try context.typeChecker.check(expression: expr.subscriptable) else {
            throw CompilerError(sourceAnchor: expr.subscriptable.sourceAnchor, message: "lvalue required in array subscript")
        }
        
        let tempAccessAddress = temporaryStack.peek()
        
        instructions += try context.compile(expression: expr.subscriptable)
        let tempBaseAddress = temporaryStack.pop()
        
        let tempArrayCount = temporaryAllocator.allocate()
        instructions += [.storeImmediate16(tempArrayCount.address, symbolType.arrayCount!)]
        
        let tempArraySize = temporaryAllocator.allocate()
        instructions += [.muli16(tempArraySize.address, tempArrayCount.address, symbolType.arrayElementType.sizeof)]
        tempArrayCount.consume()
        
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
        
        instructions += try panicOutOfBoundsError(sourceAnchor: expr.sourceAnchor)
        instructions += [.label(label)]
        
        return instructions
    }
    
    private func panicOutOfBoundsError(sourceAnchor: SourceAnchor?) throws -> [CrackleInstruction] {
        var message = "array access is out of bounds"
        if let sourceAnchor = sourceAnchor {
            message += ": `\(sourceAnchor.text)'"
            if let lineNumbers = sourceAnchor.lineNumbers {
                message += " on line \(lineNumbers.lowerBound + 1)"
            }
        }
        let panic = Expression.Call(sourceAnchor: sourceAnchor, callee: Expression.Identifier("panic"), arguments: [
            Expression.LiteralString(message)
        ])
        let instructions = try rvalueContext().compile(expression: panic)
        return instructions
    }
    
    public func dynamicArraySubscriptLvalue(_ expr: Expression.Subscript) throws -> [CrackleInstruction] {
        var instructions: [CrackleInstruction] = []
        
        let context = lvalueContext()
            
        guard let symbolType = try context.typeChecker.check(expression: expr.subscriptable) else {
            throw CompilerError(sourceAnchor: expr.subscriptable.sourceAnchor, message: "lvalue required in dynamic array subscript")
        }
        let elementType = symbolType.arrayElementType
        
        instructions += try context.compile(expression: expr.subscriptable)
        let sliceAddress = temporaryStack.pop()
        
        // Extract the array base address from the slice structure.
        let baseAddress = temporaryAllocator.allocate()
        temporaryStack.push(baseAddress)
        instructions += [.copyWordsIndirectSource(baseAddress.address, sliceAddress.address, 2)]
        sliceAddress.consume()
        
        instructions += try computeAddressOfArrayElement(expr, elementType)
        instructions += try dynamicArrayBoundsCheck(expr)
        
        return instructions
    }
    
    // Assuming the top of the stack holds an address, verify that the address
    // is within the specified dynamic array. If so then leave the address on
    // the stack as it was before this check. Else, panic with an appropriate
    // error message.
    private func dynamicArrayBoundsCheck(_ expr: Expression.Subscript) throws -> [CrackleInstruction] {
        let label = labelMaker.next()
        var instructions: [CrackleInstruction] = []
        
        let context = lvalueContext()
        guard let symbolType = try context.typeChecker.check(expression: expr.subscriptable) else {
            throw CompilerError(sourceAnchor: expr.subscriptable.sourceAnchor, message: "lvalue required in dynamic array subscript")
        }
        let tempAccessAddress = temporaryStack.peek()
        
        instructions += try lvalueContext().compile(expression: expr.subscriptable)
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
        instructions += [.storeImmediate16(tempArrayElementSize.address, symbolType.arrayElementType.sizeof)]
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
        
        instructions += try panicOutOfBoundsError(sourceAnchor: expr.sourceAnchor)
        instructions += [.label(label)]
        
        // Specifically do not consume tempAccessAddress as we need to leave
        // that in place on the stack when we're done.
        
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
        instructions += try rvalueContext().compileAndConvertExpressionForExplicitCast(rexpr: expr.argument, ltype: .u16)
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
