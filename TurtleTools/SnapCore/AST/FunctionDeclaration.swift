//
//  FunctionDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class FunctionDeclaration: AbstractSyntaxTreeNode {
    public let identifier: Expression.Identifier
    public let functionType: Expression
    public let argumentNames: [String]
    public let typeArguments: [Expression.GenericTypeArgument]
    public let body: Block
    public let visibility: SymbolVisibility
    public let symbols: SymbolTable
    
    public var isGeneric: Bool {
        !typeArguments.isEmpty
    }
    
    public init(sourceAnchor: SourceAnchor? = nil,
                identifier: Expression.Identifier,
                functionType: Expression,
                argumentNames: [String],
                typeArguments: [Expression.GenericTypeArgument] = [],
                body: Block,
                visibility: SymbolVisibility = .privateVisibility,
                symbols: SymbolTable = SymbolTable()) {
        self.identifier = identifier.withSourceAnchor(sourceAnchor)
        self.functionType = functionType.withSourceAnchor(sourceAnchor)
        self.argumentNames = argumentNames
        self.typeArguments = typeArguments
        self.body = body.withSourceAnchor(sourceAnchor)
        self.visibility = visibility
        self.symbols = symbols
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> FunctionDeclaration {
        if (self.sourceAnchor != nil) || (self.sourceAnchor == sourceAnchor) {
            return self
        }
        return FunctionDeclaration(sourceAnchor: sourceAnchor,
                                   identifier: identifier,
                                   functionType: functionType,
                                   argumentNames: argumentNames,
                                   typeArguments: typeArguments,
                                   body: body,
                                   visibility: visibility,
                                   symbols: symbols)
    }
    
    public func withBody(_ body: Block) -> FunctionDeclaration {
        FunctionDeclaration(sourceAnchor: sourceAnchor,
                            identifier: identifier,
                            functionType: functionType,
                            argumentNames: argumentNames,
                            typeArguments: typeArguments,
                            body: body,
                            visibility: visibility,
                            symbols: symbols)
    }
    
    public func clone() -> FunctionDeclaration {
        FunctionDeclaration(sourceAnchor: sourceAnchor,
                            identifier: identifier,
                            functionType: functionType,
                            argumentNames: argumentNames,
                            typeArguments: typeArguments,
                            body: body,
                            visibility: visibility,
                            symbols: symbols.clone())
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard super.isEqual(rhs) else {
            return false
        }
        guard let rhs = rhs as? FunctionDeclaration else {
            return false
        }
        guard identifier == rhs.identifier else {
            return false
        }
        guard functionType == rhs.functionType else {
            return false
        }
        guard typeArguments == rhs.typeArguments else {
            return false
        }
        guard argumentNames == rhs.argumentNames else {
            return false
        }
        guard body == rhs.body else {
            return false
        }
        guard visibility == rhs.visibility else {
            return false
        }
//        guard symbols == rhs.symbols else {
//            return false
//        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(functionType)
        hasher.combine(argumentNames)
        hasher.combine(typeArguments)
        hasher.combine(body)
        hasher.combine(visibility)
//        hasher.combine(symbols)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let parentStr: String
        if let parent = symbols.parent {
            parentStr = "\(parent)"
        } else {
            parentStr = "nil"
        }
        
        return String(format: """
            %@%@
            %@identifier: %@
            %@visibility: %@
            %@functionType: %@
            %@argumentNames: %@
            %@typeArguments: %@
            %@body: %@
            """,
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)) + "(symbols=\(symbols); parent=\(parentStr))",
                      makeIndent(depth: depth + 1),
                      identifier.makeIndentedDescription(depth: depth + 1),
                      makeIndent(depth: depth + 1),
                      visibility.description,
                      makeIndent(depth: depth + 1),
                      functionType.makeIndentedDescription(depth: depth + 1),
                      makeIndent(depth: depth + 1),
                      makeArgumentsDescription(depth: depth + 1),
                      makeIndent(depth: depth + 1),
                      makeTypeArgumentsDescription(depth: depth + 1),
                      makeIndent(depth: depth + 1),
                      body.makeIndentedDescription(depth: depth + 1))
    }
    
    fileprivate func makeArgumentsDescription(depth: Int) -> String {
        var result: String = ""
        if argumentNames.isEmpty {
            result = "none"
        } else {
            for i in 0..<argumentNames.count {
                let argument = argumentNames[i]
                result += "\n"
                result += makeIndent(depth: depth + 1)
                result += "\(i) -- \(argument)"
            }
        }
        return result
    }
    
    fileprivate func makeTypeArgumentsDescription(depth: Int) -> String {
        var result: String = ""
        if typeArguments.isEmpty {
            result = "none"
        } else {
            for i in 0..<typeArguments.count {
                let typeArgument = typeArguments[i]
                result += "\n"
                result += makeIndent(depth: depth + 1)
                result += "\(i) -- \(typeArgument)"
            }
        }
        return result
    }
}
