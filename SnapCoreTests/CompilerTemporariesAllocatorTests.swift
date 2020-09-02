//
//  CompilerTemporariesAllocatorTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/25/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore

class CompilerTemporariesAllocatorTests: XCTestCase {
    func testAllocateOneByte() {
        let size = 1
        let base = 0
        let limit = 2
        let allocator = CompilerTemporariesAllocator(base: base, limit: limit)
        let temporary = allocator.maybeAllocate(size: size)
        XCTAssertEqual(temporary?.refCount, 1)
        XCTAssertEqual(temporary?.address, base)
        XCTAssertEqual(temporary?.size, size)
    }
    
    func testAllocateTwoBytes() {
        let size = 2
        let base = 0
        let limit = 2
        let allocator = CompilerTemporariesAllocator(base: base, limit: limit)
        let temporary = allocator.maybeAllocate(size: size)
        XCTAssertEqual(temporary?.refCount, 1)
        XCTAssertEqual(temporary?.address, base)
        XCTAssertEqual(temporary?.size, size)
    }
    
    func testAllocateTwice() {
        let size = 2
        let base = 0
        let limit = 4
        let allocator = CompilerTemporariesAllocator(base: base, limit: limit)
        let temporary1 = allocator.maybeAllocate(size: size)
        let temporary2 = allocator.maybeAllocate(size: size)
        XCTAssertEqual(temporary1?.refCount, 1)
        XCTAssertEqual(temporary1?.address, base)
        XCTAssertEqual(temporary1?.size, size)
        XCTAssertEqual(temporary2?.refCount, 1)
        XCTAssertEqual(temporary2?.address, base+size)
        XCTAssertEqual(temporary2?.size, size)
    }
    
    func testAllocateAndFreeAndAllocateAgain() {
        let base = 0
        let limit = 2
        let allocator = CompilerTemporariesAllocator(base: base, limit: limit)
        let temporary1 = allocator.maybeAllocate(size: 2)
        temporary1?.consume()
        let temporary2 = allocator.maybeAllocate(size: 2)
        XCTAssertEqual(temporary1?.refCount, 0)
        XCTAssertEqual(temporary1?.address, base)
        XCTAssertEqual(temporary1?.size, 2)
        XCTAssertEqual(temporary2?.refCount, 1)
        XCTAssertEqual(temporary2?.address, base)
        XCTAssertEqual(temporary2?.size, 2)
    }
    
    func testAllocateTemporaryWhichOverlapsTwoPreviouslyFreed() {
        let base = 0
        let limit = 3
        let allocator = CompilerTemporariesAllocator(base: base, limit: limit)
        let temporary1 = allocator.maybeAllocate(size: 1)
        let temporary2 = allocator.maybeAllocate(size: 1)
        temporary1?.consume()
        temporary2?.consume()
        let temporary3 = allocator.maybeAllocate(size: 3)
        XCTAssertEqual(temporary1?.refCount, 0)
        XCTAssertEqual(temporary1?.address, 0)
        XCTAssertEqual(temporary1?.size, 1)
        XCTAssertEqual(temporary2?.refCount, 0)
        XCTAssertEqual(temporary2?.address, 1)
        XCTAssertEqual(temporary2?.size, 1)
        XCTAssertEqual(temporary3?.refCount, 1)
        XCTAssertEqual(temporary3?.address, 0)
        XCTAssertEqual(temporary3?.size, 3)
    }
    
    func testFailToAllocateBecauseSimplyTooLarge() {
        let base = 0
        let limit = 0
        let allocator = CompilerTemporariesAllocator(base: base, limit: limit)
        let temporary = allocator.maybeAllocate(size: 1)
        XCTAssertNil(temporary)
    }
    
    func testFailToAllocateBecauseOfFragmentation() {
        let base = 0
        let limit = 4
        let allocator = CompilerTemporariesAllocator(base: base, limit: limit)
        let a = allocator.maybeAllocate(size: 1)
        let b = allocator.maybeAllocate(size: 1)
        let c = allocator.maybeAllocate(size: 1)
        b?.consume()
        let d = allocator.maybeAllocate(size: 2)
        
        XCTAssertEqual(a?.refCount, 1)
        XCTAssertEqual(a?.address, 0)
        XCTAssertEqual(a?.size, 1)
        
        XCTAssertEqual(b?.refCount, 0)
        XCTAssertEqual(b?.address, 1)
        XCTAssertEqual(b?.size, 1)
        
        XCTAssertEqual(c?.refCount, 1)
        XCTAssertEqual(c?.address, 2)
        XCTAssertEqual(c?.size, 1)
        
        XCTAssertNil(d)
    }
}
