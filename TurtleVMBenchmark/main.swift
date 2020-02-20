//
//  main.swift
//  TurtleVMBenchmark
//
//  Created by Andrew Fox on 2/19/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleTTL

let driver = TurtleVMBenchmarkDriver(withArguments: CommandLine.arguments)
driver.stdout = FileHandleTextOutputStream(FileHandle.standardOutput)
driver.stderr = FileHandleTextOutputStream(FileHandle.standardError)
driver.run()
exit(driver.status)
