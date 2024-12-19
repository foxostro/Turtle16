//
//  Assert.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/1/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class Assert: AbstractSyntaxTreeNode {
    public let condition: Expression
    public let message: String
    public let enclosingTestName: String?
    
    public init(sourceAnchor: SourceAnchor? = nil,
                condition: Expression,
                message: String,
                enclosingTestName: String? = nil,
                id: ID = ID()) {
        self.condition = condition.withSourceAnchor(sourceAnchor) // TODO: Remove call to withSourceAnchor?
        self.message = message
        self.enclosingTestName = enclosingTestName
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Assert {
        Assert(sourceAnchor: sourceAnchor,
               condition: condition,
               message: message,
               enclosingTestName: enclosingTestName,
               id: id)
    }
    
    public func withCondition(_ condition: Expression) -> Assert {
        Assert(sourceAnchor: sourceAnchor,
               condition: condition,
               message: message,
               enclosingTestName: enclosingTestName,
               id: id)
    }
    
    public func withEnclosingTestName(_ enclosingTestName: String?) -> Assert {
        Assert(sourceAnchor: sourceAnchor,
               condition: condition,
               message: message,
               enclosingTestName: enclosingTestName,
               id: id)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Assert else { return false }
        guard condition == rhs.condition else { return false }
        guard message == rhs.message else { return false }
        guard enclosingTestName == rhs.enclosingTestName else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(condition)
        hasher.combine(message)
        hasher.combine(enclosingTestName)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent0 = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let selfDesc = String(describing: type(of: self))
        let indent1 = makeIndent(depth: depth + 1)
        let conditionDesc = condition.makeIndentedDescription(depth: depth + 1)
        let result = """
            \(indent0)\(selfDesc)
            \(indent1)condition: \(conditionDesc)
            \(indent1)message: \(finalMessage)
            """
        return result
    }
    
    public var finalMessage: String {
        if let enclosingTestName = enclosingTestName {
            "\(message) in test \"\(enclosingTestName)\""
        } else {
            message
        }
    }
}
