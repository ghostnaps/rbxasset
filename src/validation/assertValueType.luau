local function assertValueType(fieldValue: any, fieldName: string, expectedType: string)
	local fieldType = typeof(fieldValue)
	assert(
		fieldType == expectedType,
		`The value of "{fieldName}" must be of type {expectedType}, got {fieldType} instead`
	)
end

return assertValueType
