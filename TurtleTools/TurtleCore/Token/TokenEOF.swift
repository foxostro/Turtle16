//
//  TokenEOF.swift
//  TurtleCore
//
//  Created by Andrew Fox on 9/3/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

public class TokenEOF : Token {
    public override var description: String {
        return String(format: "<%@: sourceAnchor=%@>",
                      String(describing: type(of: self)),
                      String(describing: sourceAnchor))
    }
}
