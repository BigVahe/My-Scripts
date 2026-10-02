--!strict
local lexer = require(script.Parent:WaitForChild("lexer"))
local AST = require(script.Parent:WaitForChild("AST"))

--lexer
type Chunk = lexer.chunk
type Token = lexer.token
type TokenType = lexer.tokentype

--program
type Program = AST.Program

--statements
type VarDeclaration = AST.VarDeclaration
type Statement = AST.Statement

--Literals
type IntegerLiteral = AST.IntegerLiteral
type StringLiteral = AST.StringLiteral
type IdentifierExpression = AST.IdentifierExpression
type NullLiteral = AST.NullLiteral

--expr
type BinaryExpression = AST.BinaryExpression
type Expression = AST.Expression


local parser = {}

parser.at = function(chunk:Chunk):Token
	return chunk[1]
end

parser.eat = function(chunk:Chunk):Token
	return table.remove(chunk, 1) :: Token
end


parser.expect = function(chunk:Chunk, tokenType:TokenType, message:string):Token?
	const at = table.remove(chunk, 1) :: Token
	if at.tokenType ~= tokenType then error(message) end
	return at
end

parser.EOF_check = function(chunk:Chunk):boolean
	const at = parser.at(chunk)
	return at.tokenType == "EOF"
end
--



--
parser.Program = function(source:string):Program
	const chunk = lexer.tokenize(lexer.make_source(source)) :: Chunk
	warn(chunk)
	local Program = {
		kind = "Program",
		body = {} :: {Expression},
	} :: Program
	
	while not parser.EOF_check(chunk) do
		table.insert(Program.body, parser.Statement(chunk))
	end
	
	return Program
end

parser.Statement = function(chunk:Chunk):Statement|Expression
	if parser.at(chunk).value == "set" then
		return parser.VarDeclaration(chunk)
	elseif parser.at(chunk).value == "keep" then
		return parser.VarDeclaration(chunk)
	else
		return parser.Expression(chunk)
	end
end

parser.VarDeclaration = function(chunk:Chunk):VarDeclaration
	const isConstant = parser.eat(chunk).value == "keep"
	const name = parser.at(chunk).value
	
	parser.expect(chunk, "Equal", "Error : forgot to put equal after keep "..name)
	const value = parser.Expression(chunk)
	
	return {
		kind = "VarDeclaration";
		constant = isConstant;
		name = name;
		value = value;
	}
end

--Statement
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--Expression

parser.Expression = function(chunk:Chunk)
	return parser.Additive(chunk)
end

parser.Additive = function(chunk:Chunk):Expression
	local left = parser.Multiplicative(chunk)

	while parser.at(chunk).tokenType == "Plus" or parser.at(chunk).tokenType == "Minus" do
		const operator = parser.eat(chunk)
		const right = parser.Multiplicative(chunk)

		left = {
			kind = "BinaryExpression",
			Binop = operator,
			Left = left,
			Right = right,
		} :: BinaryExpression
	end

	return left
end

parser.Multiplicative = function(chunk:Chunk):Expression
	local left = parser.PrimaryExpression(chunk)

	while parser.at(chunk).tokenType == "Divide" or parser.at(chunk).tokenType == "Multiply" do
		const operator = parser.eat(chunk)
		const right = parser.PrimaryExpression(chunk)
		
		left = {
			kind = "BinaryExpression",
			Left = left,
			Right = right,
			Binop = operator,
		} :: BinaryExpression
	end

	return left
end

parser.PrimaryExpression = function(chunk:Chunk):Expression
	const token = parser.at(chunk)
	
	if token.tokenType == "Integer" then
		--//INT
		parser.eat(chunk)
		return {kind = "IntegerLiteral", value = tonumber(token.value)} :: IntegerLiteral
	elseif token.tokenType == "String" then
		--//STRING
		parser.eat(chunk)
		return {kind = "StringLiteral", value = token.value} :: StringLiteral
	elseif token.tokenType == "Identifier" then
		--//IDENT
		parser.eat(chunk)
		return {kind = "IdentiferExpression", name = token.value} :: IdentifierExpression
	end
	
	parser.eat(chunk)
	
	return {
		kind = "NullLiteral",
		value = "null"
	} :: NullLiteral
end

return parser
