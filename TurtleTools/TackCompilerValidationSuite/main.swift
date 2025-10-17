//
//  main.swift
//  TackCompilerValidationSuite
//
//  Created by Andrew Fox on 10/16/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

internal import ArgumentParser
import TackCompilerValidationSuiteCore

@main
struct TackCompilerValidationSuiteCLI {
    static func main() async {
        await TackCompilerValidationSuiteDriver.main()
    }
}
