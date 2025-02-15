//
//  AbstractSyntaxTreeNode.swift
//  TurtleCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

/// Abstract base class for a node in the AST manipulated by the compiler
/// Each node is intended to be an immutable object. Rewriting the tree requires
/// creating new nodes and a new tree.
open class AbstractSyntaxTreeNode: Equatable, Hashable, CustomStringConvertible {
    /// Behaviors that may be adopted when determining equality of two AST nodes
    public enum EqualityMode {
        /// Consider all fields of the two AST nodes
        case defaultEqualityMode
        
        /// Ignore source anchors on the two AST nodes
        case ignoreSourceAnchors
    }
    
    /// Control the behavior when determining equality of two AST nodes
    public static var equalityMode: EqualityMode = .defaultEqualityMode
    
    /// Source anchor connects the AST node to an exercept of the original
    /// source code from which it was derived. This is useful for producing
    /// diagnostic messages for the user.
    public let sourceAnchor: SourceAnchor?
    
    public struct CountingID: Hashable, CustomStringConvertible, Sendable {
        private static var counter: Int = 0
        private static func next() -> Int {
            let result: Int
            objc_sync_enter(ID.self)
            result = CountingID.counter
            CountingID.counter += 1
            objc_sync_exit(ID.self)
            return result
        }
        private let val: Int
        
        public init() {
            self.val = CountingID.next()
        }
        
        public var description: String {
            "ID(\(val))"
        }
    }
    public typealias ID = CountingID
    
    /// Each AST node has a unique identifier, preserved across transformations
    /// As each node is immutable, a change to the AST requires rewriting
    public let id: ID
    
    public init(sourceAnchor: SourceAnchor? = nil, id: ID = ID()) {
        self.sourceAnchor = sourceAnchor
        self.id = id
    }
    
    open func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> AbstractSyntaxTreeNode {
        fatalError("unimplemented")
    }
    
    public static func == (lhs: AbstractSyntaxTreeNode, rhs: AbstractSyntaxTreeNode) -> Bool {
        lhs.isEqual(rhs)
    }
    
    open func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard type(of: self) == type(of: rhs) else { return false }
        if AbstractSyntaxTreeNode.equalityMode != .ignoreSourceAnchors {
            guard sourceAnchor == rhs.sourceAnchor else {
                if let _ = NSClassFromString("XCTest") {
                    print("lhs sourceAnchor: \(String(describing: sourceAnchor))")
                    print("rhs sourceAnchor: \(String(describing: rhs.sourceAnchor))")
                }
                return false
            }
        }
        return true
    }
    
    open func hash(into hasher: inout Hasher) {
        hasher.combine(sourceAnchor)
    }
    
    public var description: String {
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
