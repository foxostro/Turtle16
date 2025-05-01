//
//  TokenMisc.swift
//  TurtleCore
//
//  Created by Andrew Fox on 5/29/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public final class TokenEOF: Token {}
public final class TokenNewline: Token {}
public final class TokenColon: Token {}
public final class TokenSemicolon: Token {}
public final class TokenComma: Token {}
public final class TokenEqual: Token {}
public final class TokenIdentifier: Token {}
public final class TokenLet: Token {}
public final class TokenForwardSlash: Token {}
public final class TokenParenLeft: Token {}
public final class TokenParenRight: Token {}
public final class TokenBoolean: TokenLiteral<Bool> {}
public final class TokenNumber: TokenLiteral<Int> {}
public final class TokenLiteralString: TokenLiteral<String> {}
