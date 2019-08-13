//
//  main.swift
//  TurtleAssembler
//
//  Created by Andrew Fox on 8/1/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleTTL

let driver = AssemblerCommandLineDriver(withArguments: CommandLine.arguments)
driver.run()
exit(driver.status)
