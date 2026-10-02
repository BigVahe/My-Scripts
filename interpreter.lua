--!strict
const ast = require(script.Parent.Parent:WaitForChild("FRONT END"):WaitForChild("AST"))
const lex = require(script.Parent.Parent:WaitForChild("FRONT END"):WaitForChild("lexer"))
const values = require(script.Parent:WaitForChild("values"))

--lex
type token = lex.token

-- ast
type nodes = ast.nodes
type Program = ast.Program
type StringLiteral = ast.StringLiteral
type IntegerLiteral = ast.IntegerLiteral
type BinaryExpression = ast.BinaryExpression

-- values
type integer = values.integer
type str = values.str
type bool = values.bool
type null = values.null
type runtimevalue = values.runtimevalue


------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------



const interpreter = {}

interpreter.eval_program = function(node:Program)
	const t = {}
	
	for i, n in node.body do
		table.insert(t, interpreter.eval_node(n))
	end
	
	warn(t)
	return values.null()
end

interpreter.eval_arithmatic = function(left:integer, right:integer, binop:token):bool|integer|null
	local result
	
	if binop.tokenType == "Greater" then
		result = values.boolean(left.value > right.value):: bool
	elseif binop.tokenType == "Less" then
		result = values.boolean(left.value < right.value):: bool
	elseif binop.tokenType == "Plus" then
		result = values.int(left.value + right.value) :: integer
	elseif binop.tokenType == "Minus" then
		result = values.int(left.value - right.value) :: integer
	elseif binop.tokenType == "Multiply" then
		result = values.int(left.value * right.value) :: integer
	elseif binop.tokenType == "Divide" then
		result = values.int(left.value / right.value) :: integer
	else
		result = values.null()
	end
	
	return result
end

interpreter.eval_binaryExpr = function(node:BinaryExpression):bool|integer|null
	const left = interpreter.eval_node(node.Left)
	const right = interpreter.eval_node(node.Right)
	
	if left.type == "integer" and right.type == "integer" then
		return interpreter.eval_arithmatic(left, right, node.Binop)
	else
		return {type = "null", value = "null"}
	end
end

interpreter.eval_str = function(node:StringLiteral):str
	return {type = "string", value = node.value}
end

interpreter.eval_int = function(node:IntegerLiteral):integer
	return {type = "integer", value = node.value}
end

interpreter.eval_node = function(node:nodes):runtimevalue
	
	if node.kind == "Program" then return interpreter.eval_program(node :: Program)
	elseif node.kind == "IntegerLiteral" then return interpreter.eval_int(node :: IntegerLiteral)
	elseif node.kind == "StringLiteral" then return interpreter.eval_str(node :: StringLiteral)
	elseif node.kind == "BinaryExpression" then return interpreter.eval_binaryExpr(node :: BinaryExpression)
	else
		return values.null()
	end
	
end

return interpreter
