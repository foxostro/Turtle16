//
//  SnapCompilerFrontEnd.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class SnapCompilerFrontEnd: GenericCompilerFrontEnd {
    public init() {
        super.init(lexerFactory: { SnapLexer(withString: $0) },
                   parserFactory: { SnapParser(tokens: $0) },
                   codeGeneratorFactory: { SnapCodeGenerator(assemblerBackEnd: $0) })
    }
}
