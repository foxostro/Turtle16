//
//  main.swift
//  TurtleAssembler
//
//  Created by Andrew Fox on 6/4/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

let driver = AssemblerCommandLineDriver(withArguments: CommandLine.arguments)
driver.stdout = FileHandleTextOutputStream(FileHandle.standardOutput)
driver.stderr = FileHandleTextOutputStream(FileHandle.standardError)
driver.run()
exit(driver.status)
