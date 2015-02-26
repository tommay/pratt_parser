Pratt Parser
============

A Pratt Parser.  Construct it with a Lexer that returns tokens that
define the language to be parsed and combines terms.

Pratt parsers are like recursive descent parsers but instead of having
to code a function for each production you just code up some token
objects which define their own prededence and associativity.  So it's
simple to add new tokens without having to rewrite a bunch of
recursive descent functions.

Pratt parsers are also more efficient than recursive descent parsers
since they don't need to recurse all the way down to the bottom level
to figure out what to do.

http://javascript.crockford.com/tdop/tdop.html

http://effbot.org/zone/simple-top-down-parsing.htm

http://journal.stuffwithstuff.com/2011/03/19/pratt-parsers-expression-parsing-made-easy/
