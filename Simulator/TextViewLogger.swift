//
//  TextViewLogger.swift
//  Simulator
//
//  Created by Andrew Fox on 7/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleCore

final class TextViewLogger: NSObject, Logger {
    let textView:NSTextView
    let viewUpdateQueue:ThrottledQueue
    let queue = DispatchQueue(label: "com.foxostro.TextViewLogger")
    var pendingLines:[String] = []
    
    init(textView:NSTextView) {
        self.textView = textView
        viewUpdateQueue = ThrottledQueue(queue: DispatchQueue.main, maxInterval: 1.0 / 30.0)
    }
    
    func append(_ format: String, _ args: CVarArg...) {
        queue.sync {
            let line = String(format:format, arguments:args)
            pendingLines.append(line)
            viewUpdateQueue.async {
                self.updateView()
            }
        }
    }
    
    private func updateView() {
        if let textStorage = textView.textStorage {
            textStorage.beginEditing()
            queue.sync {
                for line in pendingLines {
                    textStorage.mutableString.append(line + "\n")
                }
                pendingLines = []
            }
            textStorage.endEditing()
            textView.scrollToEndOfDocument(self)
        }
    }
    
    func clear() {
        queue.sync {
            self.pendingLines = []
            DispatchQueue.main.async {
                if let textStorage = self.textView.textStorage {
                    textStorage.mutableString.setString("")
                }
            }
        }
    }
}
