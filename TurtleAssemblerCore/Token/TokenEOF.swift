//
//  TokenEOF.swift
//  TurtleAssemblerCore
//
//  Created by Andrew Fox on 9/3/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

public class TokenEOF : Token {
    public convenience init(lineNumber: Int) {
        self.init(lineNumber: lineNumber, lexeme: "")
    }
    
    public override var description: String {
        return String(format: "<%@: lineNumber=%d>", String(describing: type(of: self)), lineNumber)
    }
}
