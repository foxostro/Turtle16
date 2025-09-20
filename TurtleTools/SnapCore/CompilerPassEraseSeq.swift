//
//  CompilerPassEraseSeq.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/28/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

public final class CompilerPassEraseSeq: CompilerPass {
    public typealias Predicate = (Seq)
        -> Bool // TODO: Consider moving the project minOS to 14+ and switching to Swift's built-in Predicate type
    let predicate: Predicate

    public init(matching predicate: @escaping Predicate) {
        self.predicate = predicate
    }

    public override func visit(seq: Seq) throws -> AbstractSyntaxTreeNode? {
        predicate(seq) ? nil : seq
    }
}

public extension AbstractSyntaxTreeNode {
    // Remove all Seqs from the AST which match the given predicate
    func eraseSeq(
        matching predicate: @escaping CompilerPassEraseSeq.Predicate
    ) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassEraseSeq(matching: predicate).run(self)
    }
}
