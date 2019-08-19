//
//  AssemblerFrontEnd.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/18/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerFrontEnd: NSObject {
    public struct AssemblerFrontEndError: Error {
        public let line: Int
        public let message: String
        
        public init(line: Int, format: String, _ args: CVarArg...) {
            self.line = line
            message = String(format:format, arguments:args)
        }
    }
    
    public func compile(_ text: String) throws -> [Instruction] {
        var result = [Instruction(opcode: 0, immediate: 0)]
        let lines = text.split(separator: "\n")
        for i in 0..<lines.count {
            let line = String(lines[i])
            if let instruction = try processLine(line, i+1) {
                result.append(instruction)
            }
        }
        return result
    }
    
    func processLine(_ line: String, _ lineNumber: Int) throws -> Instruction? {
        guard let opcode = extractOpcode(stripComments(line)) else {
            return nil
        }
        if opcode == "NOP" {
            return Instruction()
        } else {
            throw AssemblerFrontEndError(line: lineNumber,
                                         format: "no such instruction: `%@'",
                                         opcode)
        }
    }
    
    func stripComments(_ line: String) -> String {
        let regex = try! NSRegularExpression(pattern: "(^.*)//.*$")
        let maybeMatch = regex.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line))
        
        if let match = maybeMatch {
            return String(line[Range(match.range(at: 1), in: line)!])
        } else {
            return line
        }
    }
    
    func extractOpcode(_ line: String) -> String? {
        let regex = try! NSRegularExpression(pattern: "(^.*)\\b.*$")
        let maybeMatch = regex.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line))
        
        if let match = maybeMatch {
            return String(line[Range(match.range(at: 1), in: line)!]).uppercased()
        } else {
            return nil
        }
    }
}
