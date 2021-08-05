//
//  SnapSubcompilerModule.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerModule: NSObject {
    public let symbols: SymbolTable
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy, symbols: SymbolTable) {
        self.symbols = symbols
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }
    
    public func compile(_ node0: Module) throws -> Module {
        guard symbols.parent == nil else {
            throw CompilerError(sourceAnchor: node0.sourceAnchor, message: "declaration is only valid at file scope")
        }
        
        guard !symbols.existsAsModule(identifier: node0.name) else {
            throw CompilerError(sourceAnchor: node0.sourceAnchor, message: "module redefines existing module: `\(node0.name)'")
        }
        
        // Modules do not inherit symbols from the code which imports them.
        // Change the storage pointer to avoid overwriting existing symbols.
        let moduleSymbols = node0.symbols
        moduleSymbols.storagePointer = symbols.storagePointer
        
        // Compile the contents of the module, producing a new module node with
        // a populated symbol table and relevant rewritten tree.
        let node1 = Block(symbols: node0.symbols, children: node0.children)
        let compiler = SnapAbstractSyntaxTreeCompiler(memoryLayoutStrategy)
        compiler.compile(node1, actuallyDoIt: true)
        if compiler.hasError {
            let fileName = node0.sourceAnchor?.url?.lastPathComponent
            throw CompilerError.makeOmnibusError(fileName: fileName, errors: compiler.errors)
        }
        let node2 = Module(sourceAnchor: node0.sourceAnchor,
                           name: node0.name,
                           children: compiler.ast.children,
                           symbols: compiler.ast.symbols)
        
        // Update the storage pointer in the enclosing code to avoid overwriting
        // symbols imported from the module.
        symbols.storagePointer = moduleSymbols.storagePointer
        
        // Finally, record the module symbols in the symbol table.
        symbols.bind(identifier: node0.name, moduleSymbols: moduleSymbols)
        
        return node2
    }
}

