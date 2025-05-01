//
//  TextViewLogger.swift
//  Simulator
//
//  Created by Andrew Fox on 7/29/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class TextViewLogger: Logger {
    let textView: NSTextView
    let viewUpdateQueue: ThrottledQueue
    let queue = DispatchQueue(label: "com.foxostro.TextViewLogger")
    var pendingLines: [String] = []
    public var appendTrailingNewline = true

    public init(textView: NSTextView) {
        self.textView = textView
        viewUpdateQueue = ThrottledQueue(queue: DispatchQueue.main, maxInterval: 1.0 / 30.0)
    }

    public func append(_ format: String, _ args: CVarArg...) {
        queue.sync {
            let line = String(format: format, arguments: args)
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
                    if appendTrailingNewline {
                        textStorage.mutableString.append(line + "\n")
                    }
                    else {
                        textStorage.mutableString.append(line)
                    }
                }
                pendingLines = []
            }
            textStorage.endEditing()
            textView.scrollToEndOfDocument(self)
        }
    }

    public func clear() {
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
