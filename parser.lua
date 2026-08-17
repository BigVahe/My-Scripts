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
