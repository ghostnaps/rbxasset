local function assertArray(fieldValue: any, fieldName: string, expectedArrayType: string)
	local fieldType = typeof(fieldValue)
	assert(fieldType == "table", `The value of "{fieldName}" must be an array of {expectedArrayType} values`)
end

return assertArray
