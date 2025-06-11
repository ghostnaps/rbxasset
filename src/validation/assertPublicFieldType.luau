local assertValueType = require("@root/validation/assertValueType")

local function assertPublicFieldType(fieldValue: any, fieldName: string, expectedType: string)
	assert(
		fieldValue ~= nil,
		`Asset config must include a "{fieldName}" field which will be displayed on the Creator Store`
	)
	assertValueType(fieldValue, fieldName, expectedType)
end

return assertPublicFieldType
