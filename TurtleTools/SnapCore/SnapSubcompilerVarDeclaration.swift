//
//  SnapSubcompilerVarDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerVarDeclaration: NSObject {
    public let symbols: SymbolTable
    public let globalEnvironment: GlobalEnvironment
    
    public init(symbols: SymbolTable, globalEnvironment: GlobalEnvironment) {
        self.symbols = symbols
        self.globalEnvironment = globalEnvironment
    }
    
    public func compile(_ node: VarDeclaration) throws -> Expression.InitialAssignment? {
        // TODO: This is a hack to get vtable VarDeclarations to work across compiler passes before we've implemented an ImplFor compiler pass. Do that and then remove this hack.
        let ident = node.identifier.identifier
        let allowRedefinition = ident.hasPrefix("__") && ident.hasSuffix("_vtable_instance")
        
        guard allowRedefinition || !symbols.exists(identifier: node.identifier.identifier) else {
            let variable = node.isMutable ? "variable" : "constant"
            throw CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "\(variable) redefines existing symbol: `\(ident)'")
        }
        
        guard !symbols.existsAsType(identifier: node.identifier.identifier) else {
            let variable = node.isMutable ? "variable" : "constant"
            throw CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "\(variable) redefines existing type: `\(ident)'")
        }
        
        let result: Expression.InitialAssignment?

        // If the variable declaration provided an explicit type expression then
        // the type checker can determine what type it evaluates to.
        let explicitType: SymbolType?
        if let explicitTypeExpr = node.explicitType {
            explicitType = try TypeContextTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment).check(expression: explicitTypeExpr)
        } else {
            explicitType = nil
        }

        if let varDeclExpr = node.expression {
            // The type of the initial value expression may be used to infer the
            // symbol type in cases where the explicit type is not specified.
            let expressionResultType = try RvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment).check(expression: varDeclExpr)

            // An explicit array type does not specify the number of array elements.
            // If the explicit type is an array type then we must examine the
            // expression result type to determine the array length.
            var symbolType: SymbolType
            switch (expressionResultType, explicitType) {
            case (.array(count: let count, elementType: _), .array(count: _, elementType: let elementType)):
                symbolType = .array(count: count, elementType: elementType)
            default:
                if let explicitType = explicitType {
                    symbolType = explicitType
                } else {
                    // Some expression types cannot be made concrete.
                    // Convert these appropriate convertible types.
                    switch expressionResultType {
                    case .arithmeticType(.compTimeInt(let constantValue)):
                        let intClass = IntClass.smallestClassContaining(value: constantValue)
                        symbolType = .arithmeticType(.mutableInt(intClass!))
                    case .bool(.compTimeBool):
                        symbolType = .bool(.mutableBool)
                    default:
                        symbolType = expressionResultType
                    }
                }
            }
            if node.isMutable {
                symbolType = symbolType.correspondingMutableType
            } else {
                symbolType = symbolType.correspondingConstType
            }
            let symbol = try makeSymbolWithExplicitType(explicitType: symbolType, storage: node.storage, visibility: node.visibility)
            symbols.bind(identifier: node.identifier.identifier, symbol: symbol)
            attachToFrame(identifier: node.identifier.identifier, symbol: symbol)
            result = Expression.InitialAssignment(sourceAnchor: node.sourceAnchor,
                                                  lexpr: node.identifier,
                                                  rexpr: varDeclExpr)
        } else if let explicitType = explicitType {
            let symbolType = node.isMutable ? explicitType : explicitType.correspondingConstType
            let symbol = try makeSymbolWithExplicitType(explicitType: symbolType, storage: node.storage, visibility: node.visibility)
            symbols.bind(identifier: node.identifier.identifier, symbol: symbol)
            result = nil
        } else {
            throw CompilerError(sourceAnchor: node.identifier.sourceAnchor,
                                format: "unable to deduce type of %@ `%@'",
                                node.isMutable ? "variable" : "constant",
                                node.identifier.identifier)
        }

        return result
    }

    func makeSymbolWithExplicitType(explicitType: SymbolType, storage: SymbolStorage, visibility: SymbolVisibility) throws -> Symbol {
        let storage: SymbolStorage = (symbols.frame==nil) ? .staticStorage : storage
        let offset = bumpStoragePointer(explicitType, storage)
        let symbol = Symbol(type: explicitType, offset: offset, storage: storage, visibility: visibility)
        return symbol
    }

    func bumpStoragePointer(_ symbolType: SymbolType, _ storage: SymbolStorage) -> Int {
        let size = globalEnvironment.memoryLayoutStrategy.sizeof(type: symbolType)
        let frame = switch storage {
        case .staticStorage:
            globalEnvironment.staticStorageFrame
            
        case .automaticStorage:
            symbols.frame!
        }
        let offset = frame.allocate(size: size)
        return offset
    }
    
    func attachToFrame(identifier: String, symbol: Symbol) {
        let frame = switch symbol.storage {
        case .staticStorage:
            globalEnvironment.staticStorageFrame
            
        case .automaticStorage:
            symbols.frame!
        }
        frame.add(identifier: identifier, symbol: symbol)
    }
}
