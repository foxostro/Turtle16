//
//  TextViewLogger.swift
//  Simulator
//
//  Created by Andrew Fox on 7/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleTTL

class TextViewLogger: Logger {
    let textView:NSTextView
    
    init(textView:NSTextView) {
        self.textView = textView
    }
    
    override func append(_ format: String, _ args: CVarArg...) {
        if let display = textView.textStorage?.mutableString {
            let message = String(format:format, arguments:args)
            display.append(message + "\n")
            textView.scrollToEndOfDocument(self)
        }
    }
    
    func clear() {
        if let display = textView.textStorage?.mutableString {
            display.setString("")
        }
    }
}
