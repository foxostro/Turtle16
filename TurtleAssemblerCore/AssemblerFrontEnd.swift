//
//  AssemblerFrontEnd.swift
//  TurtleAssemblerCore
//
//  Created by Andrew Fox on 8/18/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleCompilerToolbox

public class AssemblerFrontEnd: GenericCompilerFrontEnd {
    public init() {
        super.init(lexerFactory: { AssemblerLexer(withString: $0) },
                   parserFactory: { AssemblerParser(tokens: $0) },
                   codeGeneratorFactory: { AssemblerCodeGenerator(assemblerBackEnd: $0) })
    }
}
