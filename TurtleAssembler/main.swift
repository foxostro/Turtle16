//
//  main.swift
//  TurtleAssembler
//
//  Created by Andrew Fox on 8/1/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleAssemblerCore

let driver = AssemblerCommandLineDriver(withArguments: CommandLine.arguments)
driver.stdout = FileHandleTextOutputStream(FileHandle.standardOutput)
driver.stderr = FileHandleTextOutputStream(FileHandle.standardError)
driver.run()
exit(driver.status)
