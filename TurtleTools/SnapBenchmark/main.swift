//
//  main.swift
//  SnapBenchmark
//
//  Created by Andrew Fox on 9/16/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

let driver = SnapBenchmarkDriver(arguments: CommandLine.arguments)
driver.stdout = FileHandleTextOutputStream(FileHandle.standardOutput)
driver.stderr = FileHandleTextOutputStream(FileHandle.standardError)
driver.run()
exit(driver.status)
