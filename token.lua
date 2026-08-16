local lexer = {}
lexer.__index = lexer

local tokensType = {
	digits = "1234567890";
	operators = "+-/*";
	symbols = "()[]{}";
	-- calculator library
	calculate = {
		"add";
		"sub";
		"div";
		"mult";
		"gamble";
		"pow"; -- exponents ^x
		"rad";
		"deg";
		"neg"; -- negate number
		"abs";
		"percent";
		"fac";
		"order"; -- 5 :: returns 5, 4, 3, 2, 1 in a tuple
		"round"; -- 0.1 = 0, 0.8 = 1 so on
		"largest"; -- 0.7 = 1, 0.1 = 1
		"smallest"; -- 0.9 = 0
		"percent"; -- returns (a/b) * 100
		"log";
		"cos";
		"sin";
		"tan";
		"pi";
		"arccos";
		"arcsin";
		"arctan";
		"e"; -- 2.718
		"exp"; -- exp(x)
		"exp_e"; -- e(x)
		"i"; -- you cant really use this but it can give stuff like 2i + 3 just define i and 3 and it will give a complex number
		"new"; -- you can create matrices [1, 3 : 4, 1] [matrix (2x2)] // vectors (3, 2, 4) (v) and that it
		"quad"; -- creates an imaginary quadrilateral (2, 2, 2, 2, true) gives a square
		"scale"; -- ((v), a) = (v) * a <-- is a scalar works for matrices
		"combine"; -- (M) * (v) [2, 4] * (2, 4) = (20)
		"dot"; -- (v) . (v)
		"dotcheck"; -- this can give 3 result : true =  1, false = -1 and 0 = nil
	};
	-- premade function library
	library = {
		"calculate"; -- calculate library
		"write";
		"lenght"; -- gives lenght of any string or table
		"switch"; -- (a), (b) = (b), (a)
		"table"; -- table library
	};	
	-- keywords
	keyword = {
		"var";
		"func";
		"if";
		"return";
		"or";
		"then";
		"and";
		"else";
		"elseif";
		"for";
		"do";
		"while";
		"in";
		"end";
	};
	-- table library
	table = {
		"add"; 
		"remove";
		"find"; -- table.find(t, 4) standard lua
		"sort";
		"delete";
	}
}

lexer.constructor = function(token)
	local token_lex = setmetatable({}, lexer)
	token_lex.value = "" -- "true", "false"
	token_lex.type = "" -- bool, keyword, etc
	token_lex.line = "" -- 1, 4, 10
	token_lex.pos = "" -- 1: func addition() func is a column 1 to 4
	return token_lex
end

lexer.tokenize = function(text)
	local token
	--
	token = text
	--
	return token
end

local text = "a"
lexer.constructor(lexer.tokenize(text))

return lexer
