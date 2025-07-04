local serde = require("@lune/serde")

type FormField = {
	value: any,
	contentType: string,
	filename: string?,
}

local function createFormDataBody(boundary: string, data: { [string]: FormField })
	local body = {}

	for key, field in data do
		local value = if field.contentType == "application/json" then serde.encode("json", field.value) else field.value

		local lines = {
			`--{boundary}`,
			`Content-Disposition: form-data; name="{key}"`
				.. if field.filename then `; filename="{field.filename}"` else "",
			`Content-Type: {field.contentType}`,
			"",
			value,
		}

		table.insert(body, table.concat(lines, "\r\n"))
	end

	table.insert(body, `--{boundary}--\r\n`)

	return table.concat(body, "\r\n")
end

local function createFormData(data: { [string]: FormField })
	local boundary = "LuauFormBoundary" .. serde.hash("md5", tostring(math.random()))
	local body = createFormDataBody(boundary, data)

	return {
		boundary = boundary,
		body = body,
	}
end

return createFormData
