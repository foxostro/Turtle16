//
//  ConcreteToneGenerator.swift
//  Simulator
//
//  Created by Andrew Fox on 5/10/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleTTL

class ConcreteToneGenerator: ToneGenerator {
    var frequency: Double = 0.0 {
        didSet {
            update()
        }
    }
    var amplitude: Double = 0.0 {
        didSet {
            update()
        }
    }
    
    private var isRunning = false
    private let oscillator = Oscillator()
    
    func update() {
        if (frequency == 0.0 || amplitude == 0.0) && isRunning {
            oscillator.stop()
            isRunning = false
        } else {
            oscillator.frequency = frequency
            oscillator.amplitude = amplitude
            if !isRunning {
                oscillator.start()
            }
            isRunning = true
        }
    }
}
