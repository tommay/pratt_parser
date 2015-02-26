# A Pratt parser.  Similar to a recursive decent parser but instead of
# coding a function for each production, the syntax is coded in a set
# of token objects that are yielded by the lexer.  New operators and
# statements can be slipped in to the language with the proper
# precedence by adding new token objects to the lexer without altering
# the code for existing tokens.  Pretty cool.
#
# lexer is an enumerator with an each method that returns token objects
# with three methods:
# lbp: return the operator precedence.  Higher numbers bind more tightly.
# nud(parser): called when the token is the first token in an expression,
#   including a recursive call to expresssion (i.e., subexpression).  For
#   Example, this would be called for a unary operator, a literal, or for
#   the "if" in the construct "if <cond> then <expr>".
#   It is the token's responsibility to call parser.expression, parser.expect,
#   and/or parser.if? to handle the remainder of the expression, if any.
# led(parser, left): called when the token is preceeded by a subexpression,
#   left.  The token may be postfix or infix.
#   It is the token's responsibility to call parser.expression, parser.expect,
#   and/or parser.if? to handle the remainder of the expression, if any,
#   and combine it with left.
# Only lbp is mandatory.  nud and led will be called only when necessary, if
# ever.
# nud and lcd can call parser.expression(rbp) to recursively parse the
# right expression.  rbp should be the token's lbp for left-associativity,
# lbp-1 for right.
#
# PrattParser.new(lexer).eval will return the result of the parse.
#
# Syntax errors aren't handled at the moment and will cause ridiculous
# exceptions to be raised such as NoMethodError.

# http://javascript.crockford.com/tdop/tdop.html
# http://effbot.org/zone/simple-top-down-parsing.htm
# http://journal.stuffwithstuff.com/2011/03/19/pratt-parsers-expression-parsing-made-easy/

class PrattParser
  def initialize(lexer)
    @lexer = Enumerator.new do |y|
      lexer.each do |token|
        y << token
      end
      y << EndToken.new
    end

    @token = nil
  end

  def eval
    @token = @lexer.next
    expression(0)
  end

  def expression(rbp)
    t = @token
    @token = @lexer.next
    left = t.nud(self)
    while rbp < @token.lbp
      t = @token
      @token = @lexer.next
      left = t.led(self, left)
    end
    left
  end

  def expect(expected_token_class = nil, &block)
    block ||= lambda do |token|
      if token.class != expected_token_class
        raise "Expected #{expected_token_class}, got #{token.class}"
      end
    end
    block.call(@token)
    @token = @lexer.next
  end

  def if?(token_class)
    if @token.class == token_class
      @token = @lexer.next
    end
  end

  class EndToken
    def lbp
      0
    end
  end
end
