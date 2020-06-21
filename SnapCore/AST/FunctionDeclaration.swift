//
//  FunctionDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class FunctionDeclaration: AbstractSyntaxTreeNode {
    public let identifier: TokenIdentifier
    public let returnType: SymbolType
    public struct Argument: Equatable, Hashable {
        let name: String
        let type: SymbolType
        
        public init(name: String, type: SymbolType) {
            self.name = name
            self.type = type
        }
    }
    public let arguments: [Argument]
    public let body: Block
    
    public required init(identifier: TokenIdentifier,
                         returnType: SymbolType,
                         arguments: [Argument],
                         body: Block) {
        self.identifier = identifier
        self.returnType = returnType
        self.arguments = arguments
        self.body = body
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? FunctionDeclaration else { return false }
        guard identifier == rhs.identifier else { return false }
        guard returnType == rhs.returnType else { return false }
        guard arguments == rhs.arguments else { return false }
        guard body == rhs.body else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(returnType)
        hasher.combine(arguments)
        hasher.combine(body)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@<%@: identifier=\"%@\", returnType=%@, arguments=[%@], body=%@>",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      identifier.lexeme,
                      String(describing: returnType),
                      makeArgumentDescriptions(depth: depth + 1),
                      body.makeIndentedDescription(depth: depth + 1))
    }
    
    public func makeArgumentDescriptions(depth: Int = 0) -> String {
        let result = arguments.map({"\($0.name) : \(String(describing: $0.type))"}).joined(separator: ", ")
        return result
    }
}
