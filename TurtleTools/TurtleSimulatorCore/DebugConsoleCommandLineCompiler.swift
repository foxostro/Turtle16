//
//  DebugConsoleCommandLineCompiler.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 4/11/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import Foundation
import TurtleCore

public final class DebugConsoleCommandLineCompiler {
    public var syntaxTree: TopLevel! = nil
    public var instructions: [DebugConsoleInstruction] = []
    public private(set) var errors: [CompilerError] = []
    public var hasError: Bool { errors.count != 0 }

    public init() {}

    public func compile(_ text: String) {
        instructions = []
        errors = []

        // Lexer pass
        let lexer = DebugConsoleCommandLineLexer(text)
        lexer.scanTokens()
        if lexer.hasError {
            errors = lexer.errors
            return
        }

        // Compile to an abstract syntax tree
        let parser = DebugConsoleCommandLineParser(
            tokens: lexer.tokens,
            lineMapper: lexer.lineMapper
        )
        parser.parse()
        if parser.hasError {
            errors = parser.errors
            return
        }
        syntaxTree = parser.syntaxTree

        // Walk the tree and generate commands for nodes.
        for child in syntaxTree.children {
            let node = child as! InstructionNode
            switch node.instruction {
            case "h", "help":
                acceptHelp(node)

            case "q", "quit":
                acceptQuit(node)

            case "reset":
                acceptReset(node)

            case "c", "continue":
                acceptContinue(node)

            case "s", "step":
                acceptStep(node)

            case "r", "reg", "regs", "registers":
                acceptReg(node)

            case "info":
                acceptInfo(node)

            case "x":
                acceptReadMemory(node)

            case "writemem":
                acceptWriteMemory(node)

            case "xi":
                acceptReadInstructions(node)

            case "writememi":
                acceptWriteInstructions(node)

            case "load":
                acceptLoad(node)

            case "save":
                acceptSave(node)

            case "disassemble":
                acceptDisassemble(node)

            default:
                errors.append(
                    CompilerError(
                        sourceAnchor: child.sourceAnchor,
                        message: "unrecognized instruction: `\(node.instruction)'"
                    )
                )
            }
        }
    }

    private func acceptHelp(_ node: InstructionNode) {
        guard node.parameters.count > 0 else {
            instructions.append(.help(nil))
            return
        }

        guard let topic = node.parameters[0] as? ParameterIdentifier else {
            instructions.append(.help(nil))
            return
        }

        switch topic.value {
        case "h", "help":
            instructions.append(.help(.help))

        case "q", "quit":
            instructions.append(.help(.quit))

        case "reset":
            instructions.append(.help(.reset))

        case "s", "step":
            instructions.append(.help(.step))

        case "r", "reg", "regs", "registers":
            instructions.append(.help(.reg))

        case "info":
            instructions.append(.help(.info))

        case "x":
            instructions.append(.help(.readMemory))

        case "writemem":
            instructions.append(.help(.writeMemory))

        case "xi":
            instructions.append(.help(.readInstructions))

        case "writememi":
            instructions.append(.help(.writeInstructions))

        case "load":
            instructions.append(.help(.load))

        case "save":
            instructions.append(.help(.save))

        case "disassemble":
            instructions.append(.help(.disassemble))

        default:
            instructions.append(.help(nil))
        }
    }

    private func acceptQuit(_ node: InstructionNode) {
        if node.parameters.count != 0 {
            errors.append(
                CompilerError(
                    sourceAnchor: node.parameters.first?.sourceAnchor,
                    message: "instruction takes no parameters: `\(node.instruction)'"
                )
            )
        }
        else {
            instructions.append(.quit)
        }
    }

    private func acceptReset(_ node: InstructionNode) {
        if node.parameters.count > 1 {
            errors.append(
                CompilerError(
                    sourceAnchor: node.parameters[1].sourceAnchor,
                    message: "instruction takes zero or one parameters: `\(node.instruction)'"
                )
            )
        }
        else {
            if let parameter = node.parameters.first {
                if let parameterIdentifier = parameter as? ParameterIdentifier {
                    switch parameterIdentifier.value {
                    case "hard":
                        instructions.append(.reset(type: .hard))

                    case "soft":
                        instructions.append(.reset(type: .soft))

                    default:
                        errors.append(
                            CompilerError(
                                sourceAnchor: parameterIdentifier.sourceAnchor,
                                message:
                                    "expected parameter to specify either a `soft' or `hard' reset: `\(parameterIdentifier.value)'"
                            )
                        )
                    }
                }
                else {
                    errors.append(
                        CompilerError(
                            sourceAnchor: parameter.sourceAnchor,
                            message:
                                "expected parameter to specify either a `soft' or `hard' reset: `\(parameter)'"
                        )
                    )
                }
            }
            else {
                instructions.append(.reset(type: .soft))
            }
        }
    }

    private func acceptContinue(_ node: InstructionNode) {
        if node.parameters.count != 0 {
            errors.append(
                CompilerError(
                    sourceAnchor: node.parameters.first?.sourceAnchor,
                    message: "instruction takes no parameters: `\(node.instruction)'"
                )
            )
        }
        else {
            instructions.append(.run)
        }
    }

    private func acceptStep(_ node: InstructionNode) {
        if node.parameters.count == 0 {
            instructions.append(.step(count: 1))
        }
        else if node.parameters.count == 1 {
            if let parameter = node.parameters.first as? ParameterNumber {
                instructions.append(.step(count: parameter.value))
            }
            else {
                errors.append(
                    CompilerError(
                        sourceAnchor: node.parameters.first?.sourceAnchor,
                        message: "expected a number for the step count: `\(node.instruction)'"
                    )
                )
            }
        }
        else {
            errors.append(
                CompilerError(
                    sourceAnchor: node.parameters[2].sourceAnchor,
                    message:
                        "instruction takes one optional parameter for the step count: `\(node.instruction)'"
                )
            )
        }
    }

    private func acceptReg(_ node: InstructionNode) {
        if node.parameters.count != 0 {
            errors.append(
                CompilerError(
                    sourceAnchor: node.parameters.first?.sourceAnchor,
                    message: "instruction takes no parameters: `\(node.instruction)'"
                )
            )
        }
        else {
            instructions.append(.reg)
        }
    }

    private func acceptInfo(_ node: InstructionNode) {
        if node.parameters.count < 2 {
            let device = node.parameters.first as? ParameterIdentifier
            instructions.append(.info(device?.value))
        }
        else {
            errors.append(
                CompilerError(
                    sourceAnchor: node.parameters[1].sourceAnchor,
                    message: "instruction takes zero or one parameters: `\(node.instruction)'"
                )
            )
        }
    }

    private func acceptReadMemory(_ node: InstructionNode) {
        if let parameters = acceptReadMemoryParameters(node) {
            instructions.append(.readMemory(base: parameters.0, count: parameters.1))
        }
    }

    private func acceptWriteMemory(_ node: InstructionNode) {
        if let parameters = acceptWriteMemoryParameters(node) {
            instructions.append(.writeMemory(base: parameters.0, words: parameters.1))
        }
    }

    private func acceptReadInstructions(_ node: InstructionNode) {
        if let parameters = acceptReadMemoryParameters(node) {
            instructions.append(.readInstructions(base: parameters.0, count: parameters.1))
        }
    }

    private func acceptReadMemoryParameters(_ node: InstructionNode) -> (UInt16, UInt)? {
        if node.parameters.count == 1 {
            if let base = node.parameters.first as? ParameterNumber {
                return (UInt16(base.value), 1)
            }
            else {
                errors.append(
                    CompilerError(
                        sourceAnchor: node.parameters.first?.sourceAnchor,
                        message: "expected a number for the memory address: `\(node.instruction)'"
                    )
                )
            }
            return nil
        }
        else if node.parameters.count == 2 {
            guard let length = (node.parameters[0] as? ParameterSlashed)?.child as? ParameterNumber
            else {
                errors.append(
                    CompilerError(
                        sourceAnchor: node.parameters[0].sourceAnchor,
                        message: "expected a number for the length: `\(node.instruction)'"
                    )
                )
                return nil
            }
            guard let base = node.parameters[1] as? ParameterNumber else {
                errors.append(
                    CompilerError(
                        sourceAnchor: node.parameters[1].sourceAnchor,
                        message: "expected a number for the memory address: `\(node.instruction)'"
                    )
                )
                return nil
            }

            guard let baseAddr = validateParameterUInt16(node, base) else {
                return nil
            }

            return (baseAddr, UInt(length.value))
        }
        else {
            errors.append(
                CompilerError(
                    sourceAnchor: node.sourceAnchor,
                    message:
                        "expected at least one parameter for the memory address: `\(node.instruction)'"
                )
            )
        }

        return nil
    }

    private func validateParameterUInt16(
        _ node: InstructionNode,
        _ param: ParameterNumber
    ) -> UInt16? {
        guard param.value <= UInt16.max && param.value >= Int16.min else {
            errors.append(
                CompilerError(
                    sourceAnchor: param.sourceAnchor,
                    message: "not enough bits to represent the passed value: `\(node.instruction)'"
                )
            )
            return nil
        }
        let baseAddr: UInt16
        if param.value < 0 {
            baseAddr = UInt16(bitPattern: Int16(param.value))
        }
        else {
            baseAddr = UInt16(param.value)
        }
        return baseAddr
    }

    private func acceptWriteInstructions(_ node: InstructionNode) {
        if let parameters = acceptWriteMemoryParameters(node) {
            instructions.append(.writeInstructions(base: parameters.0, words: parameters.1))
        }
    }

    fileprivate func acceptWriteMemoryParameters(_ node: InstructionNode) -> (UInt16, [UInt16])? {
        guard node.parameters.count >= 2 else {
            let sourceAnchor = (node.parameters.first?.sourceAnchor) ?? node.sourceAnchor
            errors.append(
                CompilerError(
                    sourceAnchor: sourceAnchor,
                    message: "expected a memory address and data words: `\(node.instruction)'"
                )
            )
            return nil
        }
        guard let base = node.parameters[0] as? ParameterNumber else {
            errors.append(
                CompilerError(
                    sourceAnchor: node.parameters[0].sourceAnchor,
                    message: "expected a number for the memory address: `\(node.instruction)'"
                )
            )
            return nil
        }
        var words: [UInt16] = []
        for el in node.parameters[1...] {
            guard let word = el as? ParameterNumber else {
                errors.append(
                    CompilerError(
                        sourceAnchor: el.sourceAnchor,
                        message: "expected a number for the data word: `\(node.instruction)'"
                    )
                )
                return nil
            }
            guard let value = validateParameterUInt16(node, word) else {
                return nil
            }
            words.append(value)
        }

        guard let baseAddr = validateParameterUInt16(node, base) else {
            return nil
        }

        return (baseAddr, words)
    }

    private func acceptLoad(_ node: InstructionNode) {
        guard (1...2).contains(node.parameters.count) else {
            let sourceAnchor = (node.parameters.last?.sourceAnchor) ?? node.sourceAnchor
            errors.append(
                CompilerError(
                    sourceAnchor: sourceAnchor,
                    message:
                        "expected one parameter for the destination and one parameter for the file path: `\(node.instruction)'"
                )
            )
            return
        }
        guard let parameterDestination = node.parameters[0] as? ParameterIdentifier else {
            errors.append(
                CompilerError(
                    sourceAnchor: node.parameters.first?.sourceAnchor,
                    message: "expected an identifier for the destination: `\(node.instruction)'"
                )
            )
            return
        }

        if node.parameters.count > 1 {
            guard let parameterPath = node.parameters[1] as? ParameterString else {
                errors.append(
                    CompilerError(
                        sourceAnchor: node.parameters[1].sourceAnchor,
                        message: "expected a string for the file path: `\(node.instruction)'"
                    )
                )
                return
            }
            let path = NSString(string: parameterPath.value).expandingTildeInPath
            let url = URL(fileURLWithPath: path)
            instructions.append(.load(parameterDestination.value, url))
        }
        else {
            let panel = NSOpenPanel()
            let response = panel.runModal()
            if response == NSApplication.ModalResponse.OK {
                if let url = panel.url {
                    instructions.append(.load(parameterDestination.value, url))
                }
            }
        }
    }

    private func acceptSave(_ node: InstructionNode) {
        guard (1...2).contains(node.parameters.count) else {
            let sourceAnchor = (node.parameters.last?.sourceAnchor) ?? node.sourceAnchor
            errors.append(
                CompilerError(
                    sourceAnchor: sourceAnchor,
                    message:
                        "expected one parameter for the source and one parameter for the file path: `\(node.instruction)'"
                )
            )
            return
        }
        guard let parameterDestination = node.parameters[0] as? ParameterIdentifier else {
            errors.append(
                CompilerError(
                    sourceAnchor: node.parameters.first?.sourceAnchor,
                    message: "expected an identifier for the source: `\(node.instruction)'"
                )
            )
            return
        }

        if node.parameters.count > 1 {
            guard let parameterPath = node.parameters[1] as? ParameterString else {
                errors.append(
                    CompilerError(
                        sourceAnchor: node.parameters[1].sourceAnchor,
                        message: "expected a string for the file path: `\(node.instruction)'"
                    )
                )
                return
            }
            let path = NSString(string: parameterPath.value).expandingTildeInPath
            let url = URL(fileURLWithPath: path)
            instructions.append(.save(parameterDestination.value, url))
        }
        else {
            let panel = NSSavePanel()
            let response = panel.runModal()
            if response == NSApplication.ModalResponse.OK {
                if let url = panel.url {
                    instructions.append(.save(parameterDestination.value, url))
                }
            }
        }
    }

    private func acceptDisassemble(_ node: InstructionNode) {
        switch node.parameters.count {
        case 0:
            instructions.append(.disassemble(.unspecified))

        case 1:
            switch node.parameters[0] {
            case let parameterBase as ParameterNumber:
                guard parameterBase.value >= 0 else {
                    errors.append(
                        CompilerError(
                            sourceAnchor: parameterBase.sourceAnchor,
                            message: "base address must not be negative: `\(node.instruction)'"
                        )
                    )
                    return
                }
                guard parameterBase.value < 65536 else {
                    errors.append(
                        CompilerError(
                            sourceAnchor: parameterBase.sourceAnchor,
                            message: "base address must be less than 65536: `\(node.instruction)'"
                        )
                    )
                    return
                }
                instructions.append(.disassemble(.base(UInt16(parameterBase.value))))

            case let parameterIdentifier as ParameterIdentifier:
                instructions.append(.disassemble(.identifier(parameterIdentifier.value)))

            default:
                errors.append(
                    CompilerError(
                        sourceAnchor: node.parameters[0].sourceAnchor,
                        message:
                            "expected an identifier or number for the base address: `\(node.instruction)'"
                    )
                )
            }

        case 2:
            switch node.parameters[0] {
            case let parameterBase as ParameterNumber:
                guard parameterBase.value >= 0 else {
                    errors.append(
                        CompilerError(
                            sourceAnchor: parameterBase.sourceAnchor,
                            message: "base address must not be negative: `\(node.instruction)'"
                        )
                    )
                    return
                }
                guard parameterBase.value < Int(UInt16.max) + 1 else {
                    errors.append(
                        CompilerError(
                            sourceAnchor: parameterBase.sourceAnchor,
                            message:
                                "base address must be less than \(Int(UInt16.max)+1): `\(node.instruction)'"
                        )
                    )
                    return
                }
                guard let parameterCount = node.parameters[1] as? ParameterNumber else {
                    errors.append(
                        CompilerError(
                            sourceAnchor: node.parameters[1].sourceAnchor,
                            message: "expected a number for the count: `\(node.instruction)'"
                        )
                    )
                    return
                }
                guard parameterCount.value >= 0 else {
                    errors.append(
                        CompilerError(
                            sourceAnchor: parameterCount.sourceAnchor,
                            message: "count must not be negative: `\(node.instruction)'"
                        )
                    )
                    return
                }
                guard parameterCount.value < Int(UInt16.max) + 1 else {
                    errors.append(
                        CompilerError(
                            sourceAnchor: parameterCount.sourceAnchor,
                            message:
                                "count must be less than \(Int(UInt16.max)+1): `\(node.instruction)'"
                        )
                    )
                    return
                }
                instructions.append(
                    .disassemble(
                        .baseCount(UInt16(parameterBase.value), UInt(parameterCount.value))
                    )
                )

            case let parameterIdentifier as ParameterIdentifier:
                guard let parameterCount = node.parameters[1] as? ParameterNumber else {
                    errors.append(
                        CompilerError(
                            sourceAnchor: node.parameters[1].sourceAnchor,
                            message: "expected a number for the count: `\(node.instruction)'"
                        )
                    )
                    return
                }
                guard parameterCount.value >= 0 else {
                    errors.append(
                        CompilerError(
                            sourceAnchor: parameterCount.sourceAnchor,
                            message: "count must not be negative: `\(node.instruction)'"
                        )
                    )
                    return
                }
                guard parameterCount.value < Int(UInt16.max) + 1 else {
                    errors.append(
                        CompilerError(
                            sourceAnchor: parameterCount.sourceAnchor,
                            message:
                                "count must be less than \(Int(UInt16.max)+1): `\(node.instruction)'"
                        )
                    )
                    return
                }
                instructions.append(
                    .disassemble(
                        .identifierCount(parameterIdentifier.value, UInt(parameterCount.value))
                    )
                )

            default:
                errors.append(
                    CompilerError(
                        sourceAnchor: node.parameters[0].sourceAnchor,
                        message:
                            "expected an identifier or number for the base address: `\(node.instruction)'"
                    )
                )
            }

        default:
            let sourceAnchor = node.parameters.last?.sourceAnchor
            errors.append(
                CompilerError(
                    sourceAnchor: sourceAnchor,
                    message: "expected zero, one, or two parameters: `\(node.instruction)'"
                )
            )
        }
    }
}
