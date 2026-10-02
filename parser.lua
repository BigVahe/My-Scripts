--!strict
local lexer = require(script.Parent:WaitForChild("lexer"))
local AST = require(script.Parent:WaitForChild("AST"))

--lexer
type Chunk = lexer.chunk
type Token = lexer.token
type TokenType = lexer.tokentype
type nodeKinds = AST.nodeKinds

--program
type Program = AST.Program

--statements
type VarDeclaration = AST.VarDeclaration
type Statement = AST.Statement

--Literals
type IntegerLiteral = AST.IntegerLiteral
type StringLiteral = AST.StringLiteral
type IdentifierExpr = AST.IdentifierExpression
type NullLiteral = AST.NullLiteral

--expr
type BinaryExpression = AST.BinaryExpression
type FunctionExpression = AST.FunctionExpression
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

parser.next = function(chunk:Chunk)
	return chunk[2]
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
	const name = parser.Expression(chunk) :: IdentifierExpr
	--
	if name.kind ~= "IdentifierExpr" then error("Error : expected identifier after declaring") end
	parser.expect(chunk, "Equal", "Error : forgot to put equal after keep ", name.name)
	--
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
	return parser.FunctionExpression(chunk)
end

parser.Param = function(chunk):{IdentifierExpr}
	const params = {}
	
	while parser.at(chunk).tokenType ~= "CloseParen" and not parser.EOF_check(chunk) do
		--
		const arg = parser.PrimaryExpression(chunk) :: IdentifierExpr
		--
		if arg.kind ~= "IdentifierExpr" then error("Arguments in parameters need to be Identifiers") end
		table.insert(params, arg)
		--
		if parser.at(chunk).tokenType ~= "CloseParen" then
			parser.expect(chunk, "Coma", "expected a coma for each argument in param")
		end
	end
	
	parser.expect(chunk, "CloseParen", "expected ')' for function")
	return params
end

parser.FunctionExpression = function(chunk:Chunk):Expression
	if parser.at(chunk).value == "define" then
		--//
		parser.eat(chunk)
		--
		local name = parser.Relational(chunk) :: IdentifierExpr
		
		if name.kind ~= "IdentifierExpr" then error("expected identifier after functionExpr") end
		parser.expect(chunk, "OpenParen", "expected '(' after defining the function"..name.name)
		
		const params : {IdentifierExpr} = parser.Param(chunk)
		const body : {Statement|Expression} = {}
		
		--//body
		while parser.at(chunk).value ~= "end" and not parser.EOF_check(chunk) do
			table.insert(body, parser.Statement(chunk))
		end
		if parser.eat(chunk).value ~= "end" then error("Expected 'end' at the end of the functionExpr") end
		
		return {
			name = name,
			body = body,
			params = params,
			kind = "FunctionExpression"
		} :: FunctionExpression
	end
	
	return parser.Relational(chunk)
end

parser.Relational = function(chunk:Chunk):Expression
	local left = parser.Additive(chunk)

	while parser.at(chunk).tokenType == "Greater" or parser.at(chunk).tokenType == "Less" do
		const operator = parser.eat(chunk)
		const right = parser.Additive(chunk)

		left = {
			kind = "BinaryExpression",
			Binop = operator,
			Left = left,
			Right = right,
		} :: BinaryExpression
	end

	return left
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
		return {kind = "IdentifierExpr", name = token.value} :: IdentifierExpr
	end
	
	parser.eat(chunk)
	
	return {
		kind = "NullLiteral",
		value = "null"
	} :: NullLiteral
end

return parser
