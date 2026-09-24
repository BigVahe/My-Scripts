-- lexer
-- first time making a language dont expect much sinc i was trash with types and i was a much worse scripter
-- alot of this is sourcedCode so yeah implementation came like half from me

local lexer = {}

lexer.TOKENS_TYPE = {
	--//keywords
	var = "var";
	const = "const";
	--//literal
	number = "numberLiteral";
	assignmentExpr = "assignmentExpr";
	--string = "string";
	identifier = "identifier";
	semiColon = "semiColon";
	
	--//operator grouping
	equal = "equal";
	binaryOperator = "binaryOperator";
	openParen = "openParen";
	closeParen = "closeParen";
	EOF = "EOF";
}

const KEYWORD = {
	"var";
	"const";
}

export type Token = {
	value:string;
	type:any;
}

lexer.token = function(value : string, type):Token
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
		if source[1] == "=" then table.insert(token, lexer.token(table.remove(source, 1), lexer.TOKENS_TYPE.equal))
		elseif source[1] == "+" or source[1] == "-" or source[1] == "*" or source[1] == "/" or source[1] == "&" then table.insert(token, lexer.token(table.remove(source, 1), lexer.TOKENS_TYPE.binaryOperator))
		elseif source[1] == "(" then table.insert(token, lexer.token(table.remove(source, 1), lexer.TOKENS_TYPE.openParen))
		elseif source[1] == ")" then table.insert(token, lexer.token(table.remove(source, 1), lexer.TOKENS_TYPE.closeParen))
		elseif source[1] == ";" then table.insert(token, lexer.token(table.remove(source, 1), lexer.TOKENS_TYPE.semiColon))
		
		else
			--// handle special characters//--
			if lexer.isDigit(source[1]) then
				local num = ""
				
				while #source > 0 and lexer.isDigit(source[1]) do
					num = num .. table.remove(source, 1)
				end
				
				table.insert(token, lexer.token(num, lexer.TOKENS_TYPE.number))
			
			--//
			elseif lexer.isLetter(source[1]) then
				local word = ""

				while #source > 0 and lexer.isLetter(source[1]) do
					word = word .. table.remove(source, 1)
				end
				
				if table.find(KEYWORD, word) then
					table.insert(token, lexer.token(word, lexer.TOKENS_TYPE[word]))
				else
					table.insert(token, lexer.token(word, lexer.TOKENS_TYPE.identifier))
				end
			elseif lexer.IsWhitespace(source[1]) then
				table.remove(source, 1) --// skip whitespace
			else
				warn("a weird character showed up, and idk what it is", "character is", source[1])
				break
			end
		end
	end
	
	table.insert(token, lexer.token("EndOfField", lexer.TOKENS_TYPE.EOF))
	--print(token)
	return token
end

return lexer


----------------
----------------

local AST = require(script.Parent:WaitForChild("AST"))
local lexer = require(script.Parent:WaitForChild("lexer"))
--//
const tokenTypeTable = lexer.TOKENS_TYPE
--//
type Token = lexer.Token
type Expression = AST.expression
type BinaryExpr = AST.BinaryExpr
type Identifier = AST.Identifier
type Statement = AST.statement
type Program = AST.Program
type NumericLiteral = AST.NumericLiteral
type VarDeclaration = AST.VarDeclaration
type AssignementExpr = AST.AssignmentExpr
--


--
local parser = {}
--local token:tokenType = {}

--//CLASS//--
--
function parser.produceAST(sourceCode:string):Program
	local tokens = lexer.tokenizer(sourceCode)
	const Program:Program = {
		kind = "Program";
		body = {};
	}
	
	while parser.endOfFieldCheck(tokens) do
		table.insert(Program.body, parser.statement(tokens))
	end
	return Program
end
--
--//FUNCTIONS//--
--
parser.at = function(token:Token):Token
	return token[1]
end
--
parser.endOfFieldCheck = function(token:Token):boolean
	return token[1].type ~= "EOF"
end
--
parser.eat = function(token:Token):Token
	const prev = table.remove(token, 1)
	return prev
end
--
parser.expect = function(token:Token, tokentypeexpected:string, potentialErrorMessage:string):Token
	const prev = table.remove(token, 1)
	if prev.type ~= tokentypeexpected then error(potentialErrorMessage, 1) end
	return prev
end
--
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

--//STATEMENTS//--

function parser.statement(token:Token)
	--SKIP
	--
	if token[1].type == tokenTypeTable.var or token[1].type == tokenTypeTable.const then
		return parser.var_declaration(token)
	else
		return parser.expression(token)
	end
end


-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-- AST


local AST = {}

export type NodeType = 
--Stmt
	"Program"
|"VarDeclaration" 

--Expression
|"Identifier" 
|"BinaryExpr" 
|"NumericLiteral"

-------------------------------------------------------------------------------

--Stmt
export type statement = {kind:NodeType}

export type Program = statement & {
	kind:"Program";
	body:{statement};
}

export type VarDeclaration = statement & {
	kind:"VarDeclaration";
	const:boolean;
	identity:string;
	value:expression?;
}

export type AssignmentExpr = expression & {
	kind:"AssignmentExpr";
	assigne:expression;
	value:expression
}

-------------------------------------------------------------------------------

--Expr
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


-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-- PARSER

--//EXPRESSIONS//--

function parser.expression(token:Token)
	return parser.assignement_Expression(token)
end

parser.assignement_Expression = function(token:Token)
	--
	const left = parser.additive_Expression(token)

	if parser.at(token).type == tokenTypeTable.equal then
		parser.eat(token)

		const value = parser.assignement_Expression(token)
		return { kind = "AssignmentExpr", assigne = left, ["value"] = value} :: AssignementExpr
	end

	return left
end

parser.var_declaration = function(token:Token)
	--
	const isConst = parser.eat(token).type == tokenTypeTable.const
	const identifier = parser.expect(token, tokenTypeTable.identifier, "expected identifier after 'var' | 'const'").value
	
	--// var x;
	if parser.at(token).type == tokenTypeTable.semiColon then
		parser.eat(token)
		if isConst then
			error("must assign value to 'const' or use 'var', no value provided to const", 1)
		else
			return { kind = "VarDeclaration", const = false, identity = identifier } :: VarDeclaration
		end
	end
	
	--// var x = "" or const x = ""
	parser.expect(token, tokenTypeTable.equal, "expected '=' after".."var"..identifier)
	return { kind = "VarDeclaration", const = isConst, identity = identifier, value = parser.expression(token)} :: VarDeclaration
end

--//EXPRESSIONS//--------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
--
function parser.additive_Expression(token:Token):BinaryExpr
	--left; right; operator--
	local left = parser.multiplicative_Expression(token)
	
	while parser.at(token).value == "+" or parser.at(token).value == "-" do
		const operator = parser.eat(token)
		const right = parser.multiplicative_Expression(token)
		
		left = {
			kind = "BinaryExpr";
			left = left;
			right = right;
			operator = operator.value;
		} :: BinaryExpr
	end
	
	return left
end

function parser.multiplicative_Expression(token:Token):Expression
	--left; right; operator--
	local left = parser.primary_Expression(token)

	while parser.at(token).value == "*" or parser.at(token).value == "/" or parser.at(token).value == "&" do
		const operator = parser.eat(token)
		const right = parser.primary_Expression(token)

		left = {
			kind = "BinaryExpr";
			left = left;
			right = right;
			operator = operator.value;
		} :: BinaryExpr
	end

	return left
end

function parser.primary_Expression(token:Token):Expression
	const tk = parser.at(token)

	if tk.type == tokenTypeTable.identifier then
		return {kind = "Identifier", symbol = parser.eat(token).value} :: Identifier
		--//
	elseif tk.type == tokenTypeTable.number then
		return {kind = "NumericLiteral", value = tonumber(parser.eat(token).value)} :: NumericLiteral
		--//
	elseif tk.type == "BinaryExpr" then
		return {kind = "BinaryExpr", parser.eat(token).value} :: BinaryExpr
		--//
	elseif tk.type == tokenTypeTable.openParen then
		parser.eat(token)
		const value = parser.expression(token)
		parser.expect(token, "closeParen", "unexpected character in parenthesis or forgot ')' to close parenthesis")
		return value
	else
		warn("broooo what is this!! fix me bro", "this token is bothering", parser.eat(token))
	end
end

return parser

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-- interpreter


local values = require(script.Parent:WaitForChild("values"))
local AST = require(script.Parent.Parent:WaitForChild("AST"))
local ENV = require(script.Parent.Parent:WaitForChild("ENV"))
--
type NodeType = AST.NodeType
type RuntimeVal = values.RuntimeVal
type NumberVal = values.NumberVal
--
type BinaryExpr = AST.BinaryExpr
type Identifier = AST.Identifier
type NumericLiteral = AST.NumericLiteral
type VarDeclaration = AST.VarDeclaration -- stmt
type Program = AST.Program
type Statement = AST.statement
type AssignmentExpr = AST.AssignmentExpr

local interpreter = {}
interpreter.tableOfInterpreter = {}

interpreter.evaluate_program = function(program:Program, env):RuntimeVal
	local lastEvaluated = { type = "null", values = "null"}
	interpreter.tableOfInterpreter = {}
	
	for i, stmt in program.body do
		lastEvaluated = interpreter.evaluate(stmt, env)
		interpreter.tableOfInterpreter[#interpreter.tableOfInterpreter + 1] = lastEvaluated
	end
	
	return lastEvaluated
end

interpreter.evaluate_numerical_arithmetic = function(left, right, operator:string):NumberVal
	--//
	local result = 0
	
	if operator == "+" then
		result = left + right;
		
	elseif operator == "-" then
		result = left - right;
		
	elseif operator == "*" then
		result = left * right;
		
	elseif operator == "/" then
		result = left / right;
		
	elseif operator == "&" then
		result = left % right;
	end
	
	return { type = "number", value = result }
end

interpreter.evaluate_binaryExpr = function(binop:BinaryExpr, env):RuntimeVal
	local left = interpreter.evaluate(binop.left, env)
	local right = interpreter.evaluate(binop.right, env)

	if left.type == "number" and right.type == "number" then
		return interpreter.evaluate_numerical_arithmetic(left.value, right.value, binop.operator)
	else
		return values.MK_null("null")
	end
end

interpreter.evaluate_identifier = function(identifier:Identifier, env):RuntimeVal
	const value = interpreter.evaluate(env:lookVar(identifier.symbol))
	return value
end

interpreter.evaluate_assigne = function(node:AssignmentExpr, env):RuntimeVal
	--
	if node.assigne.kind ~= "Identifier" then
		error("can only assign with identifiers")
	end
	
	const varName = (node.assigne :: Identifier).symbol
	
	return env:assignVar(varName, interpreter.evaluate(node.value, env))
end

interpreter.evaluate_var_declaration = function(declaration:VarDeclaration, env):RuntimeVal
	local value = declaration.value
	if not value then
		value = values.MK_null("null")
	elseif value.type ~= nil then
		return env:declareVar(declaration.identity, value, declaration.const)
	else
		local value = interpreter.evaluate(value, env)
	end
	
	return env:declareVar(declaration.identity, value, declaration.const)
end

interpreter.evaluate = function(astNode:NodeType, env):RuntimeVal
	--expressions
	if astNode.kind == "NumericLiteral" then
		return {
			type = "number"; 
			value = astNode.value
		} :: NumberVal
	elseif astNode.kind == "Identifier" then
		const value = env:lookVar(astNode.symbol)
		if value.type ~= nil then 
			return value
		elseif value then
			return interpreter.evaluate(value) 
		end
		return interpreter.evaluate_identifier(astNode, env)
	elseif astNode.kind == "BinaryExpr" then return interpreter.evaluate_binaryExpr(astNode, env)
	elseif astNode.kind == "Program" then return interpreter.evaluate_program(astNode, env)
	elseif astNode.kind == "AssignmentExpr" then return interpreter.evaluate_assigne(astNode, env)
		
	--statements
	elseif astNode.kind == "VarDeclaration" then return interpreter.evaluate_var_declaration(astNode, env)
	else
		warn("warn this ast node has not be set for interpretation issue", astNode)
	end
	
	return 
end

return interpreter


-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-- ENV

local values = require(script.Parent:WaitForChild("runTime"):WaitForChild("values"))
type runtimeVal = values.RuntimeVal

local ENV = {}
ENV.__index = ENV

ENV.setScope = function()
	
end

ENV.newENV = function(parent)
	--
	local self = setmetatable({}, ENV)
	local isGlobal = parent == nil
	
	self.variables = {}
	self.constants = {}
	self.parent = parent
	
	return self
end

function ENV:declareVar(varName:string, value:any, isConstant:boolean):runtimeVal
	if self.variables[varName] then warn("var", varName, "is already an existing variable please consider changing the name") end
	
	self.variables[varName] = value
	if isConstant then
		self.constants[varName] = value
	end
	
	return value
end

function ENV:assignVar(varName:string, value:runtimeVal):runtimeVal
	const env = self:resolve(varName)
	env.variables[varName] = value
	
	if env.constants[varName] then
		error("const "..varName.." cannot be reassigned ".."constants cannot be reassigned or changed", 1)
	end
	return value
end

function ENV:lookVar(varName):runtimeVal
	if not varName then warn(varName, "is maybe nil or worse") return values.MK_null("null") end
	const env = self:resolve(varName)
	return env.variables[varName]
end

function ENV:resolve(varName:string)
	if self.variables[varName] then return self end

	if self.parent ~= nil then
		return self.parent:resolve(varName)
	end
	
	warn("cannot resolve", varName, "it doesnt exist")
end

return ENV


-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-- value types

local values = {}

export type valueType = "null"|"number"|"boolean"

export type RuntimeVal = {
	type:valueType
}

export type NullVal = RuntimeVal & {
	type:"null";
	value:"null";
}

export type BoolVal = RuntimeVal & {
	type:"boolean";
	value:boolean;
}

export type NumberVal = RuntimeVal & {
	type:"number";
	value:number;
}

values.MK_number = function(val:number):NumberVal
	return { type = "number", value = val}
end

values.MK_boolean = function(val:boolean):BoolVal
	return { type = "boolean", value = val}
end

values.MK_null = function(val:string):NullVal
	return { type = "null", value = "null"}
end

return values
