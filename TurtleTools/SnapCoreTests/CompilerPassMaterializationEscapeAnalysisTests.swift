//
//  CompilerPassMaterializationEscapeAnalysisTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/10/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassMaterializationEscapeAnalysisTests: XCTestCase {
    private let foo = Identifier("foo")
    
    private func AddressOf(_ expr: Expression) -> Unary {
        Unary(op: .ampersand, expression: expr)
    }
    
    private func TempRef(_ i: Int) -> Identifier {
        Identifier("__temp\(i)")
    }
    
    func testUserDeclaredVariablesAreAlwaysMaterialized() throws {
        let input = Block(
            children: [
                VarDeclaration(
                    identifier: foo,
                    explicitType: PrimitiveType(.u16),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]
        )
            .reconnect(parent: nil)

        let expected = input
        
        let actual = try input.escapeAnalysis()
        XCTAssertEqual(actual, expected)
    }
    
    func testTemporariesAreIneligibleIfNonPrimitive() throws {
        let input = Block(
            children: [
                StructDeclaration(
                    identifier: Identifier("Foo"),
                    members: []
                ),
                VarDeclaration(
                    identifier: TempRef(0),
                    explicitType: Identifier("Foo"),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]
        )
            .reconnect(parent: nil)

        let expected = input
        
        let actual = try input.escapeAnalysis()
        XCTAssertEqual(actual, expected)
    }
    
    func testPrimitiveTemporariesAreIneligibleIfEscaping() throws {
        let input = Block(
            children: [
                VarDeclaration(
                    identifier: TempRef(0),
                    explicitType: PrimitiveType(.u16),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                ),
                AddressOf(TempRef(0))
            ]
        )
            .reconnect(parent: nil)

        let expected = Block(
            children: [
                VarDeclaration(
                    identifier: TempRef(0),
                    explicitType: PrimitiveType(.u16),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                ),
                AddressOf(TempRef(0))
            ]
        )
            .reconnect(parent: nil)
        
        let actual = try input.escapeAnalysis()
        XCTAssertEqual(actual, expected)
    }
    
    func testTemporariesHaveRegisterStorageIfPrimitiveAndNonEscaping() throws {
        let input = Block(
            children: [
                VarDeclaration(
                    identifier: TempRef(0),
                    explicitType: PrimitiveType(.u16),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                )
            ]
        )
            .reconnect(parent: nil)

        let expected = Block(
            children: [
                VarDeclaration(
                    identifier: TempRef(0),
                    explicitType: PrimitiveType(.u16),
                    expression: nil,
                    storage: .registerStorage(nil),
                    isMutable: false
                )
            ]
        )
            .reconnect(parent: nil)
        
        let actual = try input.escapeAnalysis()
        XCTAssertEqual(actual, expected)
    }
}
