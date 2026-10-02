--!strict
local tokenizer = {}

export type sourcecode = {string}

export type tokentype = "Identifier"
|"String"
|"Integer"
|"EOF"
|"Keyword"
|"Plus"
|"Minus"
|"Divide"
|"Multiply"
|"Equal"
|"OpenParen"
|"CloseParen"
|"CloseBracket"
|"OpenBracket"
|"Coma"
|"SemiColon"
|"Colon"
|"Greater"
|"Less"

const keywords : {[string]:boolean} = {
	--//KeyWORDS//--
	["keep"] = true;
	["set"] = true;
	
	["define"] = true;
	["end"] = true;
}

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

export type token = {
	value:string;
	tokenType:tokentype
}

export type chunk = {token}

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

tokenizer.token = function(value:string, typeT:tokentype)
	return {value = value, tokenType = typeT} :: token
end


--//JUST IF YOURE WONDERING IM OFC GOING TO USE SOURCE TO COLOR THE CODE :DD//--
tokenizer.make_source = function(self:string)
	local source : sourcecode = {}
	local i = 1
	
	while i <= #self do
		local s = self:sub(i, i)
		
		if s == "+" then
			table.insert(source, s)
			i += 1
		elseif s == "-" then
			table.insert(source, s)
			i += 1
		elseif s == "/" then
			table.insert(source, s)
			i += 1
		elseif s:match("%s+") then
			i += 1
		elseif s == "*"  then
			table.insert(source, s)
			i += 1
		elseif s == '"' then
			i += 1
			const start = i
			
			while i <= #self and self:sub(i, i) ~= '"' do
				i += 1
			end
			
			table.insert(source, self:sub(start, i))
			i+= 1
		elseif s:match("[%(%)%[%]{},;:]") then
			i += 1
			table.insert(source, s)
		elseif s:match("[<>]") then
			if s == "<" then
				table.insert(source, "&lt;")
				i += 1
			else
				table.insert(source, "&gt;")
				i += 1
			end
		else
			const start = i
			
			while i <= #self and not self:sub(i, i):match("%s+") and self:sub(i, i) ~= '"' and not self:sub(i, i):match("[%(%)%[%]{},;:]") do
				i += 1
			end
			
			table.insert(source, self:sub(start, i - 1))
		end
	end
	
	return source
end

tokenizer.tokenize = function(source:sourcecode)
	local chunk : chunk = {}
	
	for _, str in table.clone(source) do
		if str == "+" then table.insert(chunk, tokenizer.token(str, "Plus")) continue
		elseif str == "=" then table.insert(chunk, tokenizer.token(str, "Equal")) continue
		elseif str == "-" then table.insert(chunk, tokenizer.token(str, "Minus")) continue
		elseif str == "/" then table.insert(chunk, tokenizer.token(str, "Divide")) continue
		elseif str == "*" then table.insert(chunk, tokenizer.token(str, "Multiply")) continue
		elseif tonumber(str) then table.insert(chunk, tokenizer.token(str, "Integer")) continue
		elseif str:match('"') then table.insert(chunk, tokenizer.token(str:sub(0, #str - 1), "String")) continue
		elseif keywords[str] then table.insert(chunk, tokenizer.token(str, "Keyword")) continue
		elseif str == "(" then table.insert(chunk, tokenizer.token(str, "OpenParen")) continue
		elseif str == ")" then table.insert(chunk, tokenizer.token(str, "CloseParen")) continue
		elseif str == "{" then table.insert(chunk, tokenizer.token(str, "OpenBracket")) continue
		elseif str == "}" then table.insert(chunk, tokenizer.token(str, "CloseBracket")) continue
		elseif str == ":" then table.insert(chunk, tokenizer.token(str, "Colon")) continue
		elseif str == ";" then table.insert(chunk, tokenizer.token(str, "SemiColon")) continue
		elseif str == "," then table.insert(chunk, tokenizer.token(str, "Coma")) continue
		elseif str == "&lt;" then table.insert(chunk, tokenizer.token(str, "Less")) continue
		elseif str == "&gt;" then table.insert(chunk, tokenizer.token(str, "Greater")) continue
		else table.insert(chunk, tokenizer.token(str, "Identifier"))
		end
	end
	
	table.insert(chunk, tokenizer.token("EOF", "EOF"))
	return chunk
end

return tokenizer
