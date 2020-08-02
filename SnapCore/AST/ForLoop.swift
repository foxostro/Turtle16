//
//  ForLoop.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/6/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class ForLoop: AbstractSyntaxTreeNode {
    public let initializerClause: AbstractSyntaxTreeNode
    public let conditionClause: Expression
    public let incrementClause: AbstractSyntaxTreeNode
    public let body: AbstractSyntaxTreeNode
    
    public convenience init(initializerClause: AbstractSyntaxTreeNode,
                            conditionClause: Expression,
                            incrementClause: AbstractSyntaxTreeNode,
                            body: AbstractSyntaxTreeNode) {
        self.init(sourceAnchor: nil,
                  initializerClause: initializerClause,
                  conditionClause: conditionClause,
                  incrementClause: incrementClause,
                  body: body)
    }
    
    public required init(sourceAnchor: SourceAnchor?,
                         initializerClause: AbstractSyntaxTreeNode,
                         conditionClause: Expression,
                         incrementClause: AbstractSyntaxTreeNode,
                         body: AbstractSyntaxTreeNode) {
        self.initializerClause = initializerClause
        self.conditionClause = conditionClause
        self.incrementClause = incrementClause
        self.body = body
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? ForLoop else { return false }
        guard initializerClause == rhs.initializerClause else { return false }
        guard conditionClause == rhs.conditionClause else { return false }
        guard incrementClause == rhs.incrementClause else { return false }
        guard body == rhs.body else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(initializerClause)
        hasher.combine(conditionClause)
        hasher.combine(incrementClause)
        hasher.combine(body)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@<%@: initializerClause=%@,\n%@conditionClause=%@,\n%@incrementClause=%@,\n%@body=%@>",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      initializerClause.makeIndentedDescription(depth: depth + 1),
                      makeIndent(depth: depth + 1),
                      conditionClause.makeIndentedDescription(depth: depth + 1),
                      makeIndent(depth: depth + 1),
                      incrementClause.makeIndentedDescription(depth: depth + 1),
                      makeIndent(depth: depth + 1),
                      body.makeIndentedDescription(depth: depth + 1))
    }
}
