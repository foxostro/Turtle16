//
//  AbstractSyntaxTreeNode.swift
//  TurtleCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

open class AbstractSyntaxTreeNode : NSObject {
    public typealias ID = UUID
    public let sourceAnchor: SourceAnchor?
    public let id: ID
    
    public init(sourceAnchor: SourceAnchor? = nil, id: ID = ID()) {
        self.sourceAnchor = sourceAnchor
        self.id = id
    }
    
    open func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> AbstractSyntaxTreeNode {
        fatalError("unimplemented")
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
        guard let rhs = rhs as? AbstractSyntaxTreeNode else {
            return false
        }
        guard sourceAnchor == rhs.sourceAnchor else {
            if let _ = NSClassFromString("XCTest") {
                print("lhs sourceAnchor: \(String(describing: sourceAnchor))")
                print("rhs sourceAnchor: \(String(describing: rhs.sourceAnchor))")
            }
            return false
        }
        return true
    }
    
    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine(sourceAnchor)
        return hasher.finalize()
    }
    
    public override var description: String {
        makeIndentedDescription(depth: 0)
    }
    
    open func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let selfDesc = String(describing: type(of: self))
        let result = "\(indent)\(selfDesc)"
        return result
    }
    
    public func makeIndent(depth: Int) -> String {
        String(repeating: "\t", count: depth)
    }
}
