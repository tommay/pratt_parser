Gem::Specification.new do |gem|
  gem.description      = "A Pratt parser.  Create token objects to define your language.  Create a lexer to return tokens.  Call the parser to grok the language."
  gem.summary          = "A Pratt parser."
  gem.authors          = ["Tom May"]
  gem.email            = ["tom@tommay.net"]
  gem.homepage         = "https://github.com/tommay/pratt_parser"
  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- spec/*`.split("\n")
  gem.name             = "pratt_parser"
  gem.require_paths    = ["lib"]
  gem.version          = "0.1.0"
  gem.license          = "MIT"
  # Needs Enumerator which was added in 1.9.
  gem.required_ruby_version = ">= 1.9"
end
