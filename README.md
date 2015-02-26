Pratt Parser
============

A Pratt Parser.  Just a simple parsing framework.

Define tokens that describe your language and combine terms.  Write a
Lexer (an Enumerator) that produces a stream of tokens.  Instantiate a
PrattParser and call #eval to parse the stream and return whatever
your tokens want.

Pratt parsers are like recursive descent parsers but instead of having
to code a function for each production you just code up some token
objects which define their own prededence and associativity and how
subexpressions to the left and/or right are combined.  So it's simple
to add new new language features/tokens without having to rewrite a
bunch of recursive descent functions.

Pratt parsers are also more efficient than recursive descent parsers
since they don't need to recurse all the way down to the bottom level
to figure out what to do.

Read more:

http://javascript.crockford.com/tdop/tdop.html

http://effbot.org/zone/simple-top-down-parsing.htm

http://journal.stuffwithstuff.com/2011/03/19/pratt-parsers-expression-parsing-made-easy/
