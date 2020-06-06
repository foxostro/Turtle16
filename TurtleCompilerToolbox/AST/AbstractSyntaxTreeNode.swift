//
//  AbstractSyntaxTreeNode.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

open class AbstractSyntaxTreeNode : NSObject {
    public let children: [AbstractSyntaxTreeNode]
    
    public init(children: [AbstractSyntaxTreeNode] = []) {
        self.children = children
    }
    
    public func iterate(closure: (AbstractSyntaxTreeNode) throws -> Void) throws {
        try closure(self)
        for child in children {
            try closure(child)
        }
    }
    
    public static func ==(lhs: AbstractSyntaxTreeNode, rhs: AbstractSyntaxTreeNode) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    open override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        return isBaseClassPartEqual(rhs)
    }
    
    public final func isBaseClassPartEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? AbstractSyntaxTreeNode else {
            return false
        }
        guard children == rhs.children else {
            return false
        }
        return true
    }
    
    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine(children)
        return hasher.finalize()
    }
    
    public override var description: String {
        return makeIndentedDescription()
    }
    
    open func makeIndentedDescription(depth: Int = 0) -> String {
        return String(format: "%@<%@: children=[%@]>",
                      makeIndent(depth: depth),
                      String(describing: type(of: self)),
                      makeChildDescriptions(depth: depth + 1))
    }
    
    public func makeIndent(depth: Int) -> String {
        return String(repeating: "\t", count: depth)
    }
    
    public func makeChildDescriptions(depth: Int = 0) -> String {
        var result = ""
        if children.count > 0 {
            result += "\n" + children[0].makeIndentedDescription(depth: depth + 1)
            for child in children[1..<children.count] {
                result += ",\n" + child.makeIndentedDescription(depth: depth + 1)
            }
            result += "\n" + makeIndent(depth: depth)
        }
        return result
    }
}
