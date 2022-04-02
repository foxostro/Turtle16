//
//  ThrottledQueue.swift
//  TurtleCore
//
//  Created by Andrew Fox on 2/14/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class ThrottledQueue {
    let queue: DispatchQueue
    let maxInterval: Double
    
    var job: DispatchWorkItem = DispatchWorkItem(block: {})
    var previousRun: Date = Date.distantPast
    
    public init(queue: DispatchQueue, maxInterval: Double) {
        self.queue = queue
        self.maxInterval = maxInterval
    }
    
    public func async(block: @escaping () -> ()) {
        job.cancel()
        job = DispatchWorkItem(){ [weak self] in
            self?.previousRun = Date()
            block()
        }
        let delay = Date().timeIntervalSince(previousRun) > maxInterval ? 0 : maxInterval
        queue.asyncAfter(deadline: .now() + Double(delay), execute: job)
    }
}
