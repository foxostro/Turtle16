//
//  InstructionNode.swift
//  TurtleCore
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Foundation

public class InstructionNode: AbstractSyntaxTreeNode {
    public let instruction: String
    public let parameters: [Parameter]
    
    public convenience init(sourceAnchor: SourceAnchor? = nil,
                            instruction: String,
                            parameter: Parameter) {
        self.init(sourceAnchor: sourceAnchor,
                  instruction: instruction,
                  parameters: [parameter])
    }
    
    public init(sourceAnchor: SourceAnchor? = nil,
                instruction: String,
                parameters: [Parameter] = [],
                id: ID = ID()) {
        self.instruction = instruction
        self.parameters = parameters
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> InstructionNode {
        InstructionNode(sourceAnchor: sourceAnchor,
                        instruction: instruction,
                        parameters: parameters,
                        id: id)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? InstructionNode else { return false }
        guard instruction == rhs.instruction else { return false }
        guard parameters == rhs.parameters else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(instruction)
        hasher.combine(parameters)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let param = parameters.map {
            $0.makeIndentedDescription(depth: depth+1, wantsLeadingWhitespace: false)
        }.joined(separator: ", ")
        return "\(indent)\(instruction) \(param)"
    }
}
