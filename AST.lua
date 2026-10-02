--!strict
const lexer = require(script.Parent:WaitForChild("lexer"))
type Token = lexer.token
type Chunk = lexer.chunk

export type nodeKinds = 
"StringLiteral"
|"IntegerLiteral"
|"NullLiteral"
|"BinaryExpression"
|"IdentifierExpression"

export type nodes = 
IntegerLiteral
|BinaryExpression
|StringLiteral
|IdentifierExpression
|NullLiteral
|FunctionExpression
|VarDeclaration
|Program

export type Statement = VarDeclaration

export type Expression = 
IntegerLiteral
|BinaryExpression
|StringLiteral
|IdentifierExpression
|NullLiteral
|FunctionExpression

export type Program = {
	kind:"Program";
	body:{Statement|Expression}
}

-- let foo = function f(x) return x end <-- will work since functions are expressions

export type VarDeclaration = {
	kind:"VarDeclaration";
	constant:boolean;
	name:IdentifierExpression;
	value:Expression;
}




--//EXPRESSION//--

export type IntegerLiteral = {
	kind:nodeKinds;
	value:number;
}

export type StringLiteral = {
	kind:nodeKinds;
	value:string;
}

export type NullLiteral = {
	kind:nodeKinds;
	value:"null";
}

export type BinaryExpression = {
	kind:nodeKinds;
	Left:Expression;
	Right:Expression;
	Binop:Token;
}

export type IdentifierExpression = {
	kind:nodeKinds;
	name:string;
}

export type FunctionExpression = {
	kind:nodeKinds;
	name:IdentifierExpression;
	params:{IdentifierExpression};
	body:{Statement|Expression};
}

const AST = {}
return AST
