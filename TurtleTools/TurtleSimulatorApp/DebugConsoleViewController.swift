//
//  DebugConsoleViewController.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/18/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import Combine
import TurtleCore
import TurtleSimulatorCore

class DebugConsoleViewController: NSViewController, NSControlTextEditingDelegate {
    @IBOutlet var debuggerOutput: NSTextView!
    @IBOutlet var debuggerInput: NSTextField!

    let debugger: DebugConsoleActor
    var history: [String] = []
    var cursor = 0
    var subscriptions = Set<AnyCancellable>()

    required init(debugger: DebugConsoleActor) {
        self.debugger = debugger
        super.init(
            nibName: NSNib.Name("DebugConsoleViewController"),
            bundle: Bundle(for: type(of: self))
        )
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let logger = TextViewLogger(textView: debuggerOutput)
        logger.appendTrailingNewline = false
        debugger.logger = logger

        debuggerOutput.string = "\n"
        debuggerOutput.font = debuggerInput.font

        debuggerInput.becomeFirstResponder()

        subscribe()
    }

    private func subscribe() {
        NotificationCenter.default
            .publisher(for: NSWindow.didBecomeKeyNotification, object: view.window)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                debuggerInput.becomeFirstResponder()
            }
            .store(in: &subscriptions)

        NotificationCenter.default
            .publisher(for: .debuggerIsFreeRunningDidChange, object: debugger)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let isNotFreeRunning = !debugger.isFreeRunning
                debuggerInput.isEnabled = isNotFreeRunning
                if isNotFreeRunning {
                    debuggerInput.becomeFirstResponder()
                }
            }
            .store(in: &subscriptions)
    }

    @objc func windowDidBecomeKey(notification _: Notification) {
        debuggerInput.becomeFirstResponder()
    }

    @IBAction func submitCommandLine(_: Any) {
        let command: String =
            if debuggerInput.stringValue == "" {
                history.last ?? ""
            }
            else {
                debuggerInput.stringValue
            }
        debugger.eval(command) { [weak self] debugConsole in
            guard let self else { return }
            if debugConsole.shouldQuit {
                NSApplication.shared.keyWindow?.close()
            }
            debugConsole.logger.append("\n")
            debuggerInput.stringValue = ""
            history.insert(command, at: 0)
            cursor = 0
            debuggerInput.becomeFirstResponder()
        }
    }

    func control(
        _ control: NSControl,
        textView _: NSTextView,
        doCommandBy commandSelector: Selector
    ) -> Bool {
        if !history.isEmpty, control === debuggerInput {
            if commandSelector == #selector(moveUp(_:)) {
                debuggerInput.stringValue = history[cursor]
                cursor = min(cursor + 1, history.count - 1)
                return true
            }
            else if commandSelector == #selector(moveDown(_:)) {
                debuggerInput.stringValue = history[cursor]
                cursor = max(cursor - 1, 0)
                return true
            }
        }
        return false
    }
}
