//
//  SourceAnchor.swift
//  TurtleCore
//
//  Created by Andrew Fox on 7/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class SourceAnchor: NSObject {
    public let range: Range<String.Index>
    public let lineMapper: SourceLineRangeMapper
    
    public var url: URL? {
        return lineMapper.url
    }
    
    public override var description: String {
        var str = ""
        if let fileName = url?.lastPathComponent {
            str += "\(fileName): "
        }
        if let lineNumbers = lineNumberPrefix {
            str += "\(lineNumbers) "
        }
        str += text
        return str
    }
    
    public override var debugDescription: String {
        var begin = 0
        var index = lineMapper.text.startIndex
        while index != range.lowerBound {
            begin += 1
            lineMapper.text.formIndex(after: &index)
        }
        var end = begin
        index = range.lowerBound
        while index != range.upperBound {
            end += 1
            lineMapper.text.formIndex(after: &index)
        }
        return "\(begin)..\(end) --> \(text)"
    }
    
    public init(range: Range<String.Index>, lineMapper: SourceLineRangeMapper) {
        self.range = range
        self.lineMapper = lineMapper
    }
    
    public var text: Substring {
        return lineMapper.text[range]
    }
    
    public var lineNumbers: Range<Int>? {
        return lineMapper.lineNumbers(for: range)
    }
    
    public func union(_ sourceAnchor: SourceAnchor?) -> SourceAnchor {
        guard let sourceAnchor = sourceAnchor else {
            return self
        }
        let lowerBound = min(range.lowerBound, sourceAnchor.range.lowerBound)
        let upperBound = max(range.upperBound, sourceAnchor.range.upperBound)
        let combinedRange = lowerBound..<upperBound
        return SourceAnchor(range: combinedRange, lineMapper: lineMapper)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard let rhs = rhs as? SourceAnchor else {
            return false
        }
        guard text == rhs.text else {
            return false
        }
        return true
    }
    
    public var lineNumberPrefix: String? {
        var result: String? = nil
        if let lineNumbers = lineNumbers {
            if lineNumbers.count == 1 {
                result = "\(lineNumbers.lowerBound+1):"
            } else {
                result = "\(lineNumbers.lowerBound+1)..\(lineNumbers.upperBound):"
            }
        }
        return result
    }
    
    public var context: String {
        let text = lineMapper.text
        let lineRange = text.lineRange(for: range)
        let line = text[lineRange]
        var result = "\t\(line)"
        if !line.hasSuffix("\n") {
            result += "\n"
        }
        result += "\t"
        var index = lineRange.lowerBound
        while index != range.lowerBound {
            result += " "
            text.formIndex(after: &index)
        }
        result += "^"
        if index != range.upperBound {
            text.formIndex(after: &index)
        }
        while index != range.upperBound {
            result += "~"
            text.formIndex(after: &index)
        }
        return result
    }
    
    public func split() -> [SourceAnchor] {
        let text = lineMapper.text[range]
        var index = range.lowerBound
        while index != range.upperBound {
            if text[index] == "\n" {
                let lowerRange = (range.lowerBound)..<(index)
                text.formIndex(after: &index)
                let upperRange = (index)..<(range.upperBound)
                return SourceAnchor(range: lowerRange, lineMapper: lineMapper).split() +
                       SourceAnchor(range: upperRange, lineMapper: lineMapper).split()
            } else {
                text.formIndex(after: &index)
            }
        }
        return [self]
    }
}
