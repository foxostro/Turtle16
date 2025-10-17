//
//  FormatTimeTests.swift
//  TackCompilerValidationSuiteCoreTests
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import Foundation
@testable import TackCompilerValidationSuiteCore
import Testing

/// Unit tests for the `formatTime()` utility function
struct FormatTimeTests {
    // MARK: - Small values less than 1 second

    @Test func zero() {
        #expect(formatTime(0) == "0.000 sec")
    }

    @Test func justUnderOneSecond() {
        #expect(formatTime(0.999) == "0.999 sec")
    }

    @Test func halfSecond() {
        #expect(formatTime(0.5) == "0.500 sec")
    }

    @Test func quarterSecond() {
        #expect(formatTime(0.25) == "0.250 sec")
    }

    // MARK: - Two Decimal Places (1-10 seconds)

    @Test func exactlyOneSecond() {
        #expect(formatTime(1.0) == "1.00 sec")
    }

    @Test func onePointFiveSeconds() {
        #expect(formatTime(1.5) == "1.50 sec")
    }

    @Test func fiveSeconds() {
        #expect(formatTime(5.0) == "5.00 sec")
    }

    @Test func justUnderTenSeconds() {
        #expect(formatTime(9.99) == "9.99 sec")
    }

    @Test func twoPointThreeFourSeconds() {
        #expect(formatTime(2.34567) == "2.35 sec")
    }

    // MARK: - One Decimal Place with Units (>= 10 seconds)

    @Test func exactlyTenSeconds() {
        #expect(formatTime(10.0) == "10.0s")
    }

    @Test func fifteenSeconds() {
        #expect(formatTime(15.0) == "15.0s")
    }

    @Test func thirtyPointFiveSeconds() {
        #expect(formatTime(30.5) == "30.5s")
    }

    @Test func fiftyNinePointNineSeconds() {
        #expect(formatTime(59.9) == "59.9s")
    }

    // MARK: - Minutes

    @Test func exactlyOneMinute() {
        #expect(formatTime(60.0) == "1m 0.0s")
    }

    @Test func oneMinuteFifteenSeconds() {
        #expect(formatTime(75.0) == "1m 15.0s")
    }

    @Test func twoMinutesThirtyPointFiveSeconds() {
        #expect(formatTime(150.5) == "2m 30.5s")
    }

    @Test func tenMinutes() {
        #expect(formatTime(600.0) == "10m 0.0s")
    }

    @Test func fiftyNineMinutesFiftyNinePointNineSeconds() {
        #expect(formatTime(3599.9) == "59m 59.9s")
    }

    // MARK: - Hours

    @Test func exactlyOneHour() {
        #expect(formatTime(3600.0) == "1h 0.0s")
    }

    @Test func oneHourThirtyMinutes() {
        #expect(formatTime(5400.0) == "1h 30m 0.0s")
    }

    @Test func twoHoursFifteenMinutesTenSeconds() {
        #expect(formatTime(8110.0) == "2h 15m 10.0s")
    }

    @Test func twentyFourHours() {
        #expect(formatTime(86400.0) == "24h 0.0s")
    }

    @Test func threeHoursZeroMinutesFivePointThreeSeconds() {
        #expect(formatTime(10805.3) == "3h 5.3s")
    }

    // MARK: - Edge Cases and Boundary Conditions

    @Test func veryLargePositive() {
        // 1000 hours
        #expect(formatTime(3_600_000.0) == "1000h 0.0s")
    }

    @Test func exactlyNinePointNineNineNineSeconds() {
        // Just under the 10 second threshold
        #expect(formatTime(9.999) == "10.00 sec")
    }

    @Test func decimalPrecisionRounding() {
        // Test rounding behavior at format boundaries
        // Note: %.3f format shows all 3 decimal places even when trailing zeros
        #expect(formatTime(0.9995) == "1.000 sec") // Rounds to 1.000
    }

    @Test func veryLongDuration() {
        // 100 hours, 30 minutes, 45.6 seconds
        #expect(formatTime(361_845.6) == "100h 30m 45.6s")
    }

    // MARK: - Format Transitions

    @Test func transitionAtOneSecond() {
        // Test values around the 1 second boundary
        // Note: %.3f shows 3 decimal places, %.2f shows 2 decimal places
        #expect(formatTime(0.9999) == "1.000 sec") // < 1.0 uses %.3f
        #expect(formatTime(1.0001) == "1.00 sec") // >= 1.0 uses %.2f
    }

    @Test func transitionAtTenSeconds() {
        // Test values around the 10 second boundary
        #expect(formatTime(9.999) == "10.00 sec")
        #expect(formatTime(10.001) == "10.0s")
    }

    @Test func transitionAtSixtySeconds() {
        // Test values around the 1 minute boundary
        #expect(formatTime(59.9) == "59.9s")
        #expect(formatTime(60.1) == "1m 0.1s")
    }

    // MARK: - Extreme Edge Cases

    @Test func notANumber() {
        #expect(formatTime(.nan) == "NaN sec")
    }

    @Test func positiveInfinity() {
        #expect(formatTime(.infinity) == "+Inf sec")
    }

    @Test func subnormalNumber() {
        let result = formatTime(Double.leastNonzeroMagnitude)
        #expect(result == "0.000 sec")
    }

    @Test func largestRepresentableTimeInterval() {
        let result = formatTime(TimeInterval(9_007_199_254_740_991)) // 2**53 - 1
        #expect(result == "2501999792983h 36m 31.0s")
    }

    @Test func timeIntervalTooLargeToRepresent() {
        let result = formatTime(TimeInterval(9_007_199_254_740_992)) // 2**53
        #expect(result == "+Inf sec")
    }

    @Test func intMaxSeconds() {
        let result = formatTime(TimeInterval(Int.max))
        #expect(result == "+Inf sec")
    }

    @Test func greatestFiniteMagnitudeSeconds() {
        let result = formatTime(TimeInterval.greatestFiniteMagnitude)
        #expect(result == "+Inf sec")
    }
}
