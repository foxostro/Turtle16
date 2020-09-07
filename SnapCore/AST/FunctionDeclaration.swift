//
//  FunctionDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

public class FunctionDeclaration: AbstractSyntaxTreeNode {
    public let identifier: Expression.Identifier
    public let functionType: Expression
    public let body: Block
    
    public convenience init(identifier: Expression.Identifier,
                            functionType: Expression,
                            body: Block) {
        self.init(sourceAnchor: nil,
                  identifier: identifier,
                  functionType: functionType,
                  body: body)
    }
    
    public required init(sourceAnchor: SourceAnchor?,
                         identifier: Expression.Identifier,
                         functionType: Expression,
                         body: Block) {
        self.identifier = identifier
        self.functionType = functionType
        self.body = body
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
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
        return String(format: "%@<%@: identifier=%@, functionType=%@, body=%@>",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      identifier.makeIndentedDescription(depth: depth + 1),
                      functionType.makeIndentedDescription(depth: depth + 1),
                      body.makeIndentedDescription(depth: depth + 1))
    }
}
