//LEXER//
local lexer = {}
lexer.__index = lexer

lexer.constructor = function(token)
	local token_lex = setmetatable({}, lexer)
	token_lex.value = "" -- "true", "false"
	token_lex.type = "" -- bool, keyword, etc
	token_lex.line = "" -- 1, 4, 10
	token_lex.pos = "" -- 1: func addition() func is a column 1 to 4
	return token_lex
end
--// constructor later

const TOKENS_TYPE = {
	var = "var";
	number = "numberLiteral";
	string = "string";
	equal = "equal";
	binaryOperator = "binaryOperator";
	identifier = "identifier";
	openParen = "openParen";
	closeParen = "closeParen";
	EOF = "EOF";
}

export type tokenType =
	"var"
| "number"
| "string"
| "equal"
| "binaryOperator"
| "identifier"
| "openParen"
| "closeParen"
| "EOF"

const KEYWORD = {
	var = "var"
}

export type Token = {
	value:string;
	type:tokenType
}

lexer.token = function(value : string, type):tokenType
	return {value = value, type = type}
end

lexer.isLetter = function(str : string)
	const d = str:byte()
	return (d >= 65 and d <= 90) or (d >= 97 and d <= 122)
end

lexer.isDigit = function(str : string)
	const c = str:byte(1)
	return c >= string.byte("0") and c <= string.byte("9")
end

lexer.IsWhitespace = function(str : string)
	return str == ' ' or str == "\n" or str == "\t"
end

lexer.tokenizer = function(source : string)
	local token = {}
	local source = string.split(source, "")
	
	while #source > 0 do
		if source[1] == "=" then table.insert(token, lexer.token(table.remove(source, 1), TOKENS_TYPE.equal))
		elseif source[1] == "+" or source[1] == "-" or source[1] == "*" or source[1] == "/" or source[1] == "&" then table.insert(token, lexer.token(table.remove(source, 1), TOKENS_TYPE.binaryOperator))
		elseif source[1] == "(" then table.insert(token, lexer.token(table.remove(source, 1), TOKENS_TYPE.openParen))
		elseif source[1] == ")" then table.insert(token, lexer.token(table.remove(source, 1), TOKENS_TYPE.closeParen))
		else
			--// handle special characters//--
			if lexer.isDigit(source[1]) then
				local num = ""
				
				while #source > 0 and lexer.isDigit(source[1]) do
					num = num .. table.remove(source, 1)
				end
				
				table.insert(token, lexer.token(num, TOKENS_TYPE.number))
			
			--//
			elseif lexer.isLetter(source[1]) then
				local word = ""

				while #source > 0 and lexer.isLetter(source[1]) do
					word = word .. table.remove(source, 1)
				end
				
				if table.find(KEYWORD, word) then
					table.insert(token, lexer.token(word, KEYWORD[word]))
				else
					table.insert(token, lexer.token(word, TOKENS_TYPE.identifier))
				end
			elseif lexer.IsWhitespace(source[1]) then
				table.remove(source, 1) --// skip whitespace
			else
				warn("a weird character showed up, and idk what it is", "character is", source[1])
				break
			end
		end
	end
	
	table.insert(token, lexer.token("EndOfField", TOKENS_TYPE.EOF))
	return token
end

return lexer
________________________________________________________________________________________________________________________________________________________
//AST//

local AST = {}

export type NodeType = "Program" |"Identifier" |"BinaryExpr" |"NumericLiteral"

export type statement = {kind:NodeType}

export type Program = statement & {
	kind:"Program";
	body:{statement};
}

export type expression = statement & {}

export type BinaryExpr = expression & {
	kind:"BinaryExpr";
	left:expression;
	right:expression;
	operator:string;
}

export type Identifier = expression & {
	kind:"Identifier";
	symbol:string;
}

export type NumericLiteral = expression & {
	kind:"NumericLiteral";
	value:number;
}

return AST
________________________________________________________________________________________________________________________________________________________
//PARSER//
local AST = require(script.Parent:WaitForChild("AST"))
local lexer = require(script.Parent:WaitForChild("lexer"))
--//
type Token = lexer.Token
type Expression = AST.expression
type BinaryExpr = AST.BinaryExpr
type Identifier = AST.Identifier
type Statement = AST.statement
type Program = AST.Program
type NumericLiteral = AST.NumericLiteral
--


--
local parser = {}
parser.__index = parser

--local token:tokenType = {}

--//CLASS//--
parser.class = function()
	local self =  setmetatable({}, parser)
	self.token = {} :: Token
	return self
end
--

--
function parser:produceAST(sourceCode:string):Program
	self.token = lexer.tokenizer(sourceCode)
	const Program:Program = {
		kind = "Program";
		body = {};
	}
	
	while parser.endOfFieldCheck(self.token) do
		table.insert(Program.body, parser.statement(self.token))
	end
	return Program
end
--
--//FUNCTIONS//--
--
parser.at = function(token)
	return token[1]
end
--
parser.endOfFieldCheck = function(token):boolean
	return token[1].type ~= "EOF"
end
--
parser.eat = function(token)
	const prev = table.remove(token, 1)
	return prev
end
--
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

--//STATEMENTS//--

function parser.statement(token)
	--//SKIP
	return parser.expression(token)
end

function parser.expression(token)
	--/CHOSE/--
	return parser.additive_Expression(token)
end
--
function parser.additive_Expression(token):BinaryExpr
	--left; right; operator--
	local left = parser.multiplicative_Expression(token)
	
	while parser.at(token).value == "+" or parser.at(token).value == "-" do
		const operator = parser.eat(token)
		const right = parser.primary_Expression(token)
		
		left = {
			kind = "BinaryExpr";
			left;
			right;
			operator;
		} :: BinaryExpr
	end
	
	return left
end

function parser.multiplicative_Expression(token):Expression
	--left; right; operator--
	local left = parser.primary_Expression(token)

	while parser.at(token).value == "*" or parser.at(token).value == "/" or parser.at(token).value == "&" do
		const operator = parser.eat(token)
		const right = parser.primary_Expression(token)

		left = {
			kind = "BinaryExpr";
			left;
			right;
			operator;
		} :: BinaryExpr
	end

	return left
end

function parser.primary_Expression(token):Expression
	const tk = parser.at(token)

	if tk.type == "identifier" then
		return {kind = "Identifier", parser.eat(token).value} :: Identifier
		--//
	elseif tk.type == "numberLiteral"then
		return {kind = "NumericLiteral", tonumber(parser.eat(token).value)} :: NumericLiteral
		--//
	elseif tk.type == "binaryExpr" then
		return {kind = "BinaryExpr", parser.eat(token).value} :: BinaryExpr
		--//
	elseif tk.type == "openParent" then
		parser.eat(token)
		const value = parser.expression(token)
		parser.eat(token)
		return value
	else
		warn("broooo what is this!! fix me bro", "this token is bothering", parser.eat(token))
		return
	end
end

return parser
