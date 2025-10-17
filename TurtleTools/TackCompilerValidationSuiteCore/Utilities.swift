//
//  Utilities.swift
//  TackCompilerValidationSuiteCore
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import Foundation

extension ClosedRange where Bound: BinaryInteger {
    func converted<T: FixedWidthInteger>(to _: T.Type) -> ClosedRange<T>? {
        guard let lower = T(exactly: lowerBound),
              let upper = T(exactly: upperBound) else {
            return nil
        }
        return lower...upper
    }
}

extension ClosedRange where Bound: Strideable, Bound.Stride: SignedInteger {
    func batched(by size: Bound.Stride) -> [ClosedRange<Bound>] {
        stride(from: lowerBound, through: upperBound, by: size).map { start in
            // Calculate the desired end position, clamped to upperBound
            // We need to be careful about overflow when advancing near type boundaries
            let desiredAdvance = size - 1

            // Check if we can advance the full amount without exceeding upperBound
            // distance(to:) returns negative if the target is before self
            let distanceToUpperBound = start.distance(to: upperBound)
            let actualAdvance = Swift.min(desiredAdvance, distanceToUpperBound)

            let end = start.advanced(by: actualAdvance)
            return start...end
        }
    }
}

extension Collection {
    func unfold(by maxLength: Int) -> UnfoldSequence<SubSequence, Index> {
        sequence(state: startIndex) { start in
            guard start < self.endIndex else { return nil }
            let end = self.index(start, offsetBy: maxLength, limitedBy: self.endIndex) ?? self
                .endIndex
            defer { start = end }
            return self[start..<end]
        }
    }
}

func formatTime(_ seconds: TimeInterval) -> String {
    guard !seconds.isNaN else {
        return "NaN sec"
    }

    assert(seconds >= 0)

    guard seconds.isFinite else {
        return "+Inf sec"
    }

    let largestRepresentableSeconds: TimeInterval = 9_007_199_254_740_991 // 2**53 - 1
    guard seconds <= largestRepresentableSeconds else {
        return "+Inf sec"
    }

    // For very short durations, show millisecond precision
    if seconds < 1.0 {
        return String(format: "%.3f sec", seconds)
    }
    else if seconds < 10.0 {
        return String(format: "%.2f sec", seconds)
    }

    let totalSeconds = Int(seconds)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let secs = seconds.truncatingRemainder(dividingBy: 60)

    var parts: [String] = []
    if hours > 0 {
        parts.append("\(hours)h")
    }
    if minutes > 0 {
        parts.append("\(minutes)m")
    }
    parts.append(String(format: "%.1fs", secs))

    return parts.joined(separator: " ")
}
