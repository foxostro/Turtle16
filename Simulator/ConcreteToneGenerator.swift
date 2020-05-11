//
//  ConcreteToneGenerator.swift
//  Simulator
//
//  Created by Andrew Fox on 5/10/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleTTL
import AudioKit

class ConcreteToneGenerator: ToneGenerator {
    var frequency: Double = 0.0 {
        didSet {
            update()
        }
    }
    var gain: Double = 0.0 {
        didSet {
            update()
        }
    }
    
    private var isRunning = false
    private let oscillator = AKOscillator()
    
    public init() {
        AudioKit.output = oscillator
        try! AudioKit.start()
    }
    
    func update() {
        if (frequency == 0.0 || gain == 0.0) && isRunning {
            oscillator.stop()
            isRunning = false
        } else {
            oscillator.frequency = frequency
            oscillator.amplitude = gain
            if !isRunning {
                oscillator.start()
            }
            isRunning = true
        }
    }
}
