//
//  CompilerPassLinearizeLabels.swift
//  SnapCore
//
//  Created by Andrew Fox on 1/11/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import TurtleCore

fileprivate class LabelCollector: CompilerPass {
    public let prefix = ".L"
    public private(set) var labels: [String] = []
    
    /// Collect and return the names of all labels in use
    public static func collectLabels(_ ast: AbstractSyntaxTreeNode) -> [String] {
        let collector = LabelCollector()
        _ = try! collector.run(ast)
        return collector.labels
    }
    
    public override func visit(label node: LabelDeclaration) -> LabelDeclaration {
        if node.identifier.hasPrefix(prefix) {
            if nil == labels.first(where: {$0 == node.identifier}) {
                labels.append(node.identifier)
            }
        }
        return node
    }
}

fileprivate class CompilerPassRewriteLabel: CompilerPass {
    private let targets: [String]
    private let replacements: [String]
    
    public init(from targets: [String],
                to replacements: [String],
                symbols: SymbolTable? = nil) {
        self.targets = targets
        self.replacements = replacements
    }
    
    public override func visit(label node: LabelDeclaration) -> LabelDeclaration {
        node.withIdentifier(rewrite(node.identifier))
    }
    
    public override func visit(goto node: Goto) throws -> Goto {
        node.withTarget(rewrite(node.target))
    }
    
    public override func visit(gotoIfFalse node: GotoIfFalse) throws -> GotoIfFalse {
        node.withTarget(rewrite(node.target))
    }
    
    public override func visit(tack node: TackInstructionNode) throws -> TackInstructionNode {
        let nextInstruction: TackInstruction = switch node.instruction {
        case .call(let label): .call(rewrite(label))
        case .jmp(let label): .jmp(rewrite(label))
        case .la(let a, let label): .la(a, rewrite(label))
        case .bz(let a, let label): .bz(a, rewrite(label))
        case .bnz(let a, let label): .bnz(a, rewrite(label))
        case .bzw(let a, let label): .bzw(a, rewrite(label))
        default: node.instruction
        }
        return node.withInstruction(nextInstruction)
    }
    
    private func rewrite(_ ident: String) -> String {
        if let index = targets.firstIndex(of: ident) {
            replacements[index]
        }
        else {
            ident
        }
    }
}

fileprivate extension AbstractSyntaxTreeNode {
    /// Rewrite references to the specified label
    func rewriteLabels(
        from targets: [String],
        to replacements: [String],
        globalEnvironment: GlobalEnvironment
    ) throws -> AbstractSyntaxTreeNode? {
        guard targets != replacements else { return self }
        let result = try CompilerPassRewriteLabel(
            from: targets,
            to: replacements)
        .run(self)
        return result
    }
}

extension AbstractSyntaxTreeNode {
    /// Rewrite labels in the module to avoid collisions with names in the specified symbol table
    public func linearizeLabels(
        relativeTo symbols: SymbolTable,
        globalEnvironment: GlobalEnvironment
    ) throws -> AbstractSyntaxTreeNode? {
        let from = LabelCollector.collectLabels(self)
        guard !from.isEmpty else { return self }
        let to = (0..<from.count).map { _ in symbols.nextLabel() }
        let result = try rewriteLabels(
            from: from,
            to: to,
            globalEnvironment: globalEnvironment)
        return result
    }
}

extension Block {
    func eraseBlock(
        relativeTo symbols: SymbolTable,
        globalEnvironment: GlobalEnvironment
    ) throws -> Seq {
        let block1 = try linearizeLabels(
            relativeTo: symbols,
            globalEnvironment: globalEnvironment) as! Block
        let seq = Seq(
            sourceAnchor: block1.sourceAnchor,
            children: block1.children)
        return seq
    }
}
