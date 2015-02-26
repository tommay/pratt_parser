# Need a lot more tests than this but it's a start.

require "rubygems"
require "bundler/setup"
require "minitest/autorun"
require "pratt_parser"

describe PrattParser do
#  it "parses an empty expression" do
#    lexer = Enumerator.new {}
#    PrattParser.new(lexer).eval.must_be nil
#  end

  it "calls nud(self) for the first token in a (sub)expression" do
    token = MiniTest::Mock.new
    lexer = Enumerator.new do |y|
      y << token
    end
    parser = PrattParser.new(lexer)
    token.expect(:nud, "ok", [parser])
    parser.eval.must_equal "ok"
    token.verify
  end

  it "moves on to the next token on a valid expect" do
    class TokenA
      def nud(parser)
        parser.expect(TokenB)
        "A"
      end
    end
    class TokenB; end
    class TokenC
      def lbp; 0; end
    end

    expected_token = MiniTest::Mock.new
    expected_token.expect(:class, TokenB, [])

    fetched_expected_token = false
    lexer = Enumerator.new do |y|
      y << TokenA.new
      y << expected_token
      fetched_expected_token = true
      y << TokenC.new
    end

    PrattParser.new(lexer).eval

    assert fetched_expected_token
  end

  it "fails on invalid expect" do
    class TokenA
      def nud(parser)
        parser.expect(TokenC)
        "A"
      end
    end
    class TokenB; end
    class TokenC; end

    unexpected_token = MiniTest::Mock.new
    unexpected_token.expect(:class, TokenB, [])
    unexpected_token.expect(:class, TokenB, [])

    lexer = Enumerator.new do |y|
      y << TokenA.new
      y << unexpected_token
    end

    assert_raises RuntimeError do
      PrattParser.new(lexer).eval
    end
  end

end
