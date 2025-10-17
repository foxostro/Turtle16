//
//  ProgressSpinner.swift
//  TackCompilerValidationSuiteCore
//
//  Created by Andrew Fox on 10/19/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import Foundation

final class ProgressSpinner {
    private let frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    private var currentIndex = 0

    var currentFrame: String {
        frames[currentIndex]
    }

    func advance() {
        currentIndex = (currentIndex + 1) % frames.count
    }
}
