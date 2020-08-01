//
//  SourceAnchor.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 7/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class SourceAnchor: NSObject {
    let range: Range<String.Index>
    let lineMapper: SourceLineRangeMapper
    
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
}
