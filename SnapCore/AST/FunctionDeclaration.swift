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
    public let functionType: FunctionType
    public let body: Block
    
    public required init(identifier: TokenIdentifier,
                         functionType: FunctionType,
                         body: Block) {
        self.identifier = identifier
        self.functionType = functionType
        self.body = body
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? FunctionDeclaration else { return false }
        guard identifier == rhs.identifier else { return false }
        guard functionType == rhs.functionType else { return false }
        guard body == rhs.body else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(functionType)
        hasher.combine(body)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@<%@: identifier=\"%@\", functionType=%@, body=%@>",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      identifier.lexeme,
                      functionType.description,
                      body.makeIndentedDescription(depth: depth + 1))
    }
}
