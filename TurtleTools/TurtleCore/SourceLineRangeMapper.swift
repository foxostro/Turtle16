//
//  SourceLineRangeMapper.swift
//  TurtleCore
//
//  Created by Andrew Fox on 7/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class SourceLineRangeMapper: NSObject {
    public let url: URL?
    public let text: String
    let lineRanges: [Range<String.Index>]
    
    public convenience init(text: String) {
        self.init(url: nil, text: text)
    }
    
    public init(url: URL?, text: String) {
        self.url = url
        self.text = text
        var lineRanges: [Range<String.Index>] = []
        var index = text.startIndex
        while index != text.endIndex {
            let range = text.lineRange(for: index..<index)
            lineRanges.append(range)
            index = range.upperBound
        }
        self.lineRanges = lineRanges
    }
    
    public func lineNumbers(for range: Range<String.Index>) -> Range<Int>? {
        var lowerBound: Int? = nil
        var upperBound: Int? = nil
        for i in 0..<lineRanges.count {
            let lineRange = lineRanges[i]
            if lineRange.overlaps(range) {
                upperBound = i
                if lowerBound == nil {
                    lowerBound = i
                }
            }
        }
        if nil == lowerBound {
            return (lineRanges.count-1)..<lineRanges.count
        }
        if nil == upperBound {
            return (lineRanges.count-1)..<lineRanges.count
        }
        return lowerBound!..<(upperBound!+1)
    }
    
    public func anchor(_ begin: Int, _ end: Int) -> SourceAnchor {
        assert(begin <= end)
        assert(text.distance(from: text.startIndex, to: text.endIndex) >= end, "Anchor has bad end index of \(end) when largest valid index is \(text.distance(from: text.startIndex, to: text.endIndex))")
        assert(text.distance(from: text.startIndex, to: text.endIndex) >= begin, "Anchor has bad begin index of \(begin) when largest valid index is \(text.distance(from: text.startIndex, to: text.endIndex))")
        let range = text.index(text.startIndex, offsetBy: begin) ..< text.index(text.startIndex, offsetBy: end)
        return SourceAnchor(range: range, lineMapper: self)
    }
}
