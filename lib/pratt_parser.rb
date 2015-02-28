# A Pratt parser.  Similar to a recursive descent parser but instead of
# coding a function for each production, the syntax is coded in a set
# of token objects that are yielded by the lexer.  New operators and
# statements can be slipped into the language with the proper
# precedence by adding new token objects to the lexer without altering
# the code for existing tokens.  Pretty cool.
#
# lexer is must have an +#each+ method that returns token objects.  A token
# has three methods:
# +lbp+::
#   Returns the operator precedence.  Higher numbers bind more tightly.
# <tt>nud(parser)</tt>::
#   Called when the token is the first token in an expression,
#   including a recursive call to +expresssion+ (i.e., subexpression).
#   For example, +nud+ would be called for a unary operator, a literal,
#   or for the "if" in the construct "if <cond> then <expr>".  It is
#   the token's responsibility to call +parser.expression+,
#   +parser.expect+, and/or +parser.if?+ to handle the remainder of the
#   (sub)expression, if any.
# <tt>led(parser, left)</tt>::
#   Called when the token is preceeded by a subexpression, passed in
#   as +left+.  The token may be postfix or infix.  It is the token's
#   responsibility to call +parser.expression+, +parser.expect+,
#   and/or +parser.if?+ to handle the remainder of the expression, if
#   any, and combine it with +left+.
#
# Only +lbp+ is mandatory.  +nud+ and +led+ will be called only when
# necessary, if ever.  For example, +nud+ will never be called for a
# strictly infix token. If the token appears at the start of a
# (sub)expression then an exception that isn't at al appropriate
# to the abstraction will be thrown.
#
# +nud+ and +led+ can call <tt>parser.expression(rbp)</tt> to recursively
# parse the right subexpression.  +rbp+ should be the token's +lbp+ for
# left-associativity, +lbp-1+ for right.
#
# <tt>PrattParser.new(lexer).eval</tt> will return the result of the parse.
#
# Syntax errors aren't handled at the moment and will cause ridiculous
# exceptions to be raised such as +NoMethodError+.
#
# Further reading:
# * http://javascript.crockford.com/tdop/tdop.html
# * http://effbot.org/zone/simple-top-down-parsing.htm
# * http://journal.stuffwithstuff.com/2011/03/19/pratt-parsers-expression-parsing-made-easy/

class PrattParser
  # Creates a new +PrattParser+.  +lexer+ is an +Enumerable+, or something
  # with an +#each+ method.
  #
  def initialize(lexer)
    @lexer = Enumerator.new do |y|
      lexer.each do |token|
        y << token
      end
      y << EndToken.new
    end

    @token = nil
  end

  # Runs the tokens through the parse engine and returns the result,
  # or throws some exception on parse error.
  #
  def eval
    @token = @lexer.next
    expression(0)
  end

  # For use by token +#led+ methods to parse subexpressions with
  # binding power less than +rbp+.  Whatever that means.  Don't worry,
  # it just does the Right Thing.
  #
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

  # Checks whether the lookahead token is of the
  # +expected_token_class+ and raises an exception if it isn't.
  # Alternatively a block may be given; the block is passed the
  # lookahead token and should raise an exception if it's not an
  # expected token.  In either case if no exception is raised then the
  # lookahead token is consumed.
  #
  # +expect+ can be used to match the
  # right parenthesis in a parenthesized expression, the colon in a
  # "cond ? then : else" expression, etc.
  #
  def expect(expected_token_class = nil, &block)
    block ||= lambda do |token|
      if token.class != expected_token_class
        raise "Expected #{expected_token_class}, got #{token.class}"
      end
    end
    block.call(@token)
    @token = @lexer.next
  end

  # Checks whether the lookahead token is of the
  # +token_class+.  If it is, consumes the lookahead token
  # and returns truthy, else just returns falsy.
  # Alternatively a block can be given which is passed the token
  # and should return truthy or falssy.
  #
  # +if?+ can be used for optional tokens such as the +else+
  # clause in "if cond then val1 [else val2] end".
  #
  def if?(token_class, &block)
    block ||= lambda do |token|
      token.class == token_class
    end
    if block.call(@token)
      @token = @lexer.next
    end
  end

  class EndToken
    def lbp
      0
    end
  end
end
