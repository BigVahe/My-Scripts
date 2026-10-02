--!strict
export type runtimevalue = bool
|str
|integer
|null

export type bool = {
	type:"boolean",
	value:boolean,
}

export type str = {
	type:"string",
	value:string,
}

export type integer = {
	type:"integer",
	value:number,
}

export type null = {
	type:"null",
	value:"null",
}


------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------


const values = {}

values.int = function(n:number):integer
	return {type = "integer", value = n}
end

values.str = function(str:string):str
	return {type = "string", value = str}
end

values.boolean = function(bool:boolean):bool
	return {type = "boolean", value = bool}
end

values.null = function():null
	return {type = "null", value = "null"}
end

return values
