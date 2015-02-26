#!/usr/bin/env ruby

# Parses simple arithmetic expressions using a PrattParser.  Supports
# +, -, *, /, ^ (with customary precedence and associativity), and
# parentheses.  + and - may be either prefix or infix.  The parse
# returns a tree of *Node objects which is printed prefix-style ala
# Lisp.
#
# Numeric integer constants are supported using single-digit tokens
# which are left-associative.

require "pratt_parser"

class UnaryNode
  def initialize(operator, node)
    @operator = operator
    @node = node
  end

  def to_s
    "(#{@operator} #{@node})"
  end

  # Returns a pretty-print version of the expression ala Lisp.

  def pp(indent = "")
    newindent = indent + "  "
    "#{indent}(#{@operator}\n#{@node.pp(newindent)})"
  end

end

class BinaryNode
  def initialize(operator, left, right)
    @operator = operator
    @left = left
    @right = right
  end

  def to_s
    "(#{@operator} #{@left} #{@right})"
  end

  # Returns a pretty-print version of the expression ala Lisp.

  def pp(indent = "")
    newindent = indent + "  "
    "#{indent}(#{@operator}\n#{@left.pp(newindent)}\n#{@right.pp(newindent)})"
  end
end

class NumberNode
  def initialize(number)
    @number = number
  end

  def number
    @number
  end

  def to_s
    @number.to_s
  end

  # Returns a pretty-print version of the expression ala Lisp.

  def pp(indent = "")
    "#{indent}#{@number}"
  end
end

class TreeBuilder
  def self.eval(expression)
    PrattParser.new(Lexer.new(expression)).eval
  end

  class Lexer
    # Note that new returns an Enumerator, not a Lexer.

    def self.new(expression)
      Enumerator.new do |y|
        expression.each_char do |c|
          # Discard spaces.
          if c != " "
            y << @@tokens[c]
          end
        end
      end
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
      def initialize(operator, lbp, associates = :left)
        super(lbp)
        @operator = operator
        @rbp = (associates == :left ? lbp : lbp - 1)
      end

      def led(parser, left)
        right = parser.expression(@rbp)
        BinaryNode.new(@operator, left, right)
      end
    end

    # A Bifix token can be either prefix (via nud) or infix (via lcd).

    class BifixToken < InfixToken
      def nud(parser)
        # Bind super-right to the right.
        right = parser.expression(1000000)
        UnaryNode.new(@operator, right)
      end
    end

    class DigitToken < Token
      def initialize(lbp, value)
        super(lbp)
        @value = value
      end
      
      def nud(parser)
        NumberNode.new(@value)
      end

      def led(parser, left)
        NumberNode.new(left.number*10 + @value)
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

    def self.infix(char, lbp, associates = :left)
      token(char, InfixToken.new(char, lbp, associates))
    end

    def self.bifix(char, lbp)
      token(char, BifixToken.new(char, lbp, :left))
    end

    token("(", LeftParenToken.new(1))
    token(")", RightParenToken.new(1))

    infix("=", 10)
    bifix("+", 20)
    bifix("-", 20)
    infix("*", 30)
    infix("/", 30)
    infix("^", 40, :right)

    (0..9).each do |d|
      token(d.to_s, DigitToken.new(100, d))
    end
  end
end

if __FILE__ == $0
  tree = TreeBuilder.eval(ARGV[0])
  puts tree.to_s
  puts tree.pp
end
