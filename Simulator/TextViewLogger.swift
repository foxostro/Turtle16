//
//  TextViewLogger.swift
//  Simulator
//
//  Created by Andrew Fox on 7/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleTTL

class TextViewLogger: NSObject, Logger {
    let textView:NSTextView
    
    init(textView:NSTextView) {
        self.textView = textView
    }
    
    func append(_ format: String, _ args: CVarArg...) {
        let line = String(format:format, arguments:args)
        DispatchQueue.main.async {
            if let textStorage = self.textView.textStorage {
                textStorage.mutableString.append(line + "\n")
                self.textView.scrollToEndOfDocument(self)
            }
        }
    }
    
    func clear() {
        DispatchQueue.main.async {
            if let textStorage = self.textView.textStorage {
                textStorage.mutableString.setString("")
            }
        }
    }
}
