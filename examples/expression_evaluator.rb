#!/usr/bin/env ruby

# Evaluate simple arithmetic expressions using a PrattParser.
# Supports +, -, *, /, ^ (with customary precedence and associativity,
# and parentheses.  Also supports = to compare numbers and booleans.
# Adding support for < and > would be a simple matter of adding some
# more tokens.
#
# Supporting whitespace needs a lexer that throws away whitespace.
#
# Numeric integer constants are supported using single-digit tokens
# which are left-associatiuve.

require "pratt_parser"

class PrattEvaluator
  def self.eval(expression)
    PrattParser.new(Lexer.new(expression)).eval
  end

  class Lexer
    # Note that new returns an Enumerator, not a Lexer.

    def self.new(expression)
      expression.each_char.lazy.map{|c|@@tokens[c]}
    end

    class Token
      def initialize(lbp)
        @lbp = lbp
      end

      def lbp
        @lbp
      end
    end

    class InfixToken < Token
      def initialize(lbp, associates = :left, &block)
        super(lbp)
        @block = block
        @rbp = (associates == :left ? lbp : lbp - 1)
      end

      def led(parser, left)
        @block.call(left, parser.expression(@rbp))
      end
    end

    class DigitToken < Token
      def initialize(lbp, value)
        super(lbp)
        @value = value
      end
      
      def nud(parser)
        @value
      end
      
      def led(parser, left)
        left*10 + @value
      end
    end
    
    class LeftParenToken < Token
      def nud(parser)
        parser.expression(lbp).tap do
          parser.expect(RightParenToken)
        end
      end
    end
    
    class RightParenToken < Token
    end
    
    @@tokens = {}
    
    def self.token(char, t)
      @@tokens[char] = t
    end

    def self.infix(char, lbp, associates = :left, &block)
      token(char, InfixToken.new(lbp, associates, &block))
    end

    token("(", LeftParenToken.new(0))
    token(")", RightParenToken.new(0))

    infix("=", 10, &:==)
    infix("+", 20, &:+)
    infix("-", 20, &:-)
    infix("*", 30, &:*)
    infix("/", 30, &:/)
    infix("^", 40, :right, &:**)

    (0..9).each do |d|
      token(d.to_s, DigitToken.new(100, d.to_f))
    end
  end
end

if __FILE__ == $0
  puts PrattEvaluator.eval(ARGV[0])
end
