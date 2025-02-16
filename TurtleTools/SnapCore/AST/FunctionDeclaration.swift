//
//  FunctionDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Declare a function and its body
public final class FunctionDeclaration: AbstractSyntaxTreeNode {
    public let identifier: Identifier
    public let functionType: FunctionType
    public let argumentNames: [String]
    public let typeArguments: [GenericTypeArgument]
    public let body: Block
    public let visibility: SymbolVisibility
    public let symbols: Env
    
    public var isGeneric: Bool {
        !typeArguments.isEmpty
    }
    
    public init(sourceAnchor: SourceAnchor? = nil,
                identifier: Identifier,
                functionType: FunctionType,
                argumentNames: [String],
                typeArguments: [GenericTypeArgument] = [],
                body: Block,
                visibility: SymbolVisibility = .privateVisibility,
                symbols: Env = Env(),
                id: ID = ID()) {
        self.identifier = identifier
        self.functionType = functionType
        self.argumentNames = argumentNames
        self.typeArguments = typeArguments
        self.body = body
        self.visibility = visibility
        self.symbols = symbols
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> FunctionDeclaration {
        FunctionDeclaration(sourceAnchor: sourceAnchor,
                            identifier: identifier,
                            functionType: functionType,
                            argumentNames: argumentNames,
                            typeArguments: typeArguments,
                            body: body,
                            visibility: visibility,
                            symbols: symbols,
                            id: id)
    }
    
    public func withBody(_ body: Block) -> FunctionDeclaration {
        FunctionDeclaration(sourceAnchor: sourceAnchor,
                            identifier: identifier,
                            functionType: functionType,
                            argumentNames: argumentNames,
                            typeArguments: typeArguments,
                            body: body,
                            visibility: visibility,
                            symbols: symbols,
                            id: id)
    }
    
    public func withFunctionType(_ functionType: FunctionType) -> FunctionDeclaration {
        FunctionDeclaration(sourceAnchor: sourceAnchor,
                            identifier: identifier,
                            functionType: functionType,
                            argumentNames: argumentNames,
                            typeArguments: typeArguments,
                            body: body,
                            visibility: visibility,
                            symbols: symbols,
                            id: id)
    }
    
    public func withIdentifier(_ name: String) -> FunctionDeclaration {
        FunctionDeclaration(sourceAnchor: sourceAnchor,
                            identifier: identifier.withIdentifier(name),
                            functionType: functionType,
                            argumentNames: argumentNames,
                            typeArguments: typeArguments,
                            body: body,
                            visibility: visibility,
                            symbols: symbols,
                            id: id)
    }
    
    public func eraseTypeArguments() -> FunctionDeclaration {
        withTypeArguments([])
    }
    
    public func withTypeArguments(_ typeArguments: [GenericTypeArgument]) -> FunctionDeclaration {
        FunctionDeclaration(sourceAnchor: sourceAnchor,
                            identifier: identifier,
                            functionType: functionType,
                            argumentNames: argumentNames,
                            typeArguments: typeArguments,
                            body: body,
                            visibility: visibility,
                            symbols: symbols,
                            id: id)
    }
    
    public func clone() -> FunctionDeclaration {
        FunctionDeclaration(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            functionType: functionType,
            argumentNames: argumentNames,
            typeArguments: typeArguments,
            body: body.clone(),
            visibility: visibility,
            symbols: symbols.clone(),
            id: ID())
    }
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard identifier == rhs.identifier else { return false }
        guard functionType == rhs.functionType else { return false }
        guard typeArguments == rhs.typeArguments else { return false }
        guard argumentNames == rhs.argumentNames else { return false }
        guard body == rhs.body else { return false }
        guard visibility == rhs.visibility else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(identifier)
        hasher.combine(functionType)
        hasher.combine(argumentNames)
        hasher.combine(typeArguments)
        hasher.combine(body)
        hasher.combine(visibility)
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent0 = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let indent1 = makeIndent(depth: depth+1)
        let parentStr = if let parent = symbols.parent {
            "\(parent)"
        } else {
            "nil"
        }
        return """
            \(indent0)\(selfDesc)(symbols=\(symbols); parent=\(parentStr))
            \(indent1)identifier: \(identifier.makeIndentedDescription(depth: depth + 1))
            \(indent1)visibility: \(visibility)
            \(indent1)functionType: \(functionType.makeIndentedDescription(depth: depth + 1))
            \(indent1)argumentNames: \(makeArgumentsDescription(depth: depth + 1))
            \(indent1)typeArguments: \(makeTypeArgumentsDescription(depth: depth + 1))
            \(indent1)body: \(body.makeIndentedDescription(depth: depth + 1))
            """
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
