#!/usr/bin/env ruby

# Parses simple arithmetic expressions using a PrattParser.  Supports
# +, -, *, /, ^, ?: (with customary precedence and associativity), and
# parentheses.  + and - may be either prefix or infix.  The parse
# returns a tree of *Node objects which is printed prefix-style ala
# Lisp.
#
# Numeric integer constants are supported using single-digit tokens
# which are left-associative.

require "bundler/setup"
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

class TernaryNode
  def initialize(operator, cond, if_expr, else_expr)
    @operator = operator
    @cond = cond
    @if_expr = if_expr
    @else_expr = else_expr
  end

  def to_s
    if @else_expr
      "(#{@operator} #{@cond} #{@if_expr} #{@else_expr})"
    else
      "(#{@operator} #{@cond} #{@if_expr})"
    end
  end

  # Returns a pretty-print version of the expression ala Lisp.

  def pp(indent = "")
    newindent = indent + "  "
    if @else_expr
      "#{indent}(#{@operator}\n#{@cond.pp(newindent)}\n#{@if_expr.pp(newindent)}\n#{@else_expr.pp(newindent)})"
    else
      "#{indent}(#{@operator}\n#{@cond.pp(newindent)}\n#{@if_expr.pp(newindent)})"
    end
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
        expression.scan(%r{\b(?:if|then|else|end)\b|\S}) do |token|
          y << @@tokens[token]
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
        # Bind super-tight to the right.
        right = parser.expression(1000000)
        UnaryNode.new(@operator, right)
      end
    end

    class PostfixToken < Token
      def initialize(function, lbp)
        super(lbp)
        @function = function
      end

      def led(parser, left)
        UnaryNode.new(@function, left)
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
    
    class QuestionToken < Token
      def led(parser, cond)
        if_expr = parser.expression(lbp)
        parser.expect(ColonToken)
        else_expr = parser.expression(lbp)
        TernaryNode.new("?", cond, if_expr, else_expr)
      end
    end

    class ColonToken < Token
    end

    class IfToken < Token
      def nud(parser)
        cond = parser.expression(lbp)
        parser.expect{|token| token.expect("then")}
        then_expr = parser.expression(lbp)
        if parser.if?{|token| token.if?("else")}
          else_expr = parser.expression(lbp)
        end
        parser.expect{|token| token.expect("end")}
        TernaryNode.new("if", cond, then_expr, else_expr)
      end
    end

    class KeywordToken < Token
      def initialize(lbp, keyword)
        super(lbp)
        @keyword = keyword
      end

      def expect(keyword)
        if keyword != @keyword
          raise "Expected #{keyword} token, got #{@keyword}"
        end
      end

      def if?(keyword)
        keyword == @keyword
      end
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

    def self.postfix(char, lbp, function, &block)
      token(char, PostfixToken.new(function, lbp))
    end

    token("(", LeftParenToken.new(1))
    token(")", RightParenToken.new(1))

    infix("=", 10)
    token("if", IfToken.new(12))
    token("then", KeywordToken.new(12, "then"))
    token("else", KeywordToken.new(12, "else"))
    token("end", KeywordToken.new(12, "end"))
    token("?", QuestionToken.new(15))
    token(":", ColonToken.new(15))
    bifix("+", 20)
    bifix("-", 20)
    infix("*", 30)
    infix("/", 30)
    infix("^", 40, :right)
    postfix("!", 50, "factorial")

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
