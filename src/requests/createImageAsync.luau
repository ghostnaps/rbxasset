local fs = require("@lune/fs")
local net = require("@lune/net")
local serde = require("@lune/serde")

type FormField = {
	value: any,
	type: string,
	filename: string?,
}

local function createFormDataBody(boundary: string, data: { [string]: FormField })
	local body = {}

	for key, field in data do
		local lines = {
			boundary,
			`Content-Disposition: form-data; name="{key}"`
				.. if field.filename then `; filename="{field.filename}"` else "",
			`Content-Type: {field.type}`,
			"",
			field.value,
		}

		table.insert(body, table.concat(lines, "\r\n"))
	end

	table.insert(body, `{boundary}--\r\n`)

	return table.concat(body, "\r\n")
end

local function createFormData(data: { [string]: FormField })
	local boundary = "--LuauFormBoundary" .. serde.hash("md5", tostring(math.random()))
	local body = createFormDataBody(boundary, data)

	return {
		boundary = boundary,
		body = body,
	}
end

local function createImageAsync(
	displayName: string,
	imagePath: string,
	creatorId: number,
	creatorType: "User" | "Group",
	apiKey: string
): string?
	local creatorIdKey = if creatorType == "User" then "userId" else "groupId"

	local request = serde.encode("json", {
		assetType = "Image",
		displayName = displayName,
		creationContext = {
			creator = {
				[creatorIdKey] = creatorId,
			},
		},
	})

	local formData = createFormData({
		request = {
			value = request,
			type = "text/plain",
		},
		fileContent = {
			filename = imagePath,
			value = buffer.fromstring(fs.readFile(imagePath)),
			type = "image/png",
		},
	})

	print("formData.body", formData.body)

	local res = net.request({
		url = "https://apis.roblox.com/assets/v1/assets",
		method = "POST",
		headers = {
			["x-api-key"] = apiKey,
			["Content-Type"] = `multipart/form-data; boundary={formData.boundary}`,
		},
		body = formData.body,
	})

	print("body", res.body)

	local body = serde.decode("json", res.body)

	return body.operationId
end

return createImageAsync
