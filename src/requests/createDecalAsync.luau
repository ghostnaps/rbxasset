local fs = require("@lune/fs")
local net = require("@lune/net")
local serde = require("@lune/serde")

local function createFormData(data: { [string]: { value: any, type: string } })
	local boundary = "--" .. serde.hash("md5", tostring(math.random()))
	local body = ""
	for key, field in data do
		body ..= boundary .. "\r\nContent-Disposition: form-data; name=" .. key .. "\r\nContent-type: " .. field.type .. "\r\n\r\n" .. field.value .. "\r\n"
	end
	body ..= boundary .. "--\r\n"

	return body
end

local function createDecalAsync(
	displayName: string,
	imagePath: string,
	creatorId: number,
	creatorType: "User" | "Group",
	apiKey: string
): string?
	local creatorIdKey = if creatorType == "User" then "userId" else "groupId"

	local request = serde.encode("json", {
		assetType = "Decal",
		displayName = displayName,
		creationContext = {
			creator = {
				[creatorIdKey] = creatorId,
			},
		},
	})

	local imageContent = fs.readFile(imagePath)

	local res = net.request({
		url = "https://apis.roblox.com/assets/v1/assets",
		method = "POST",
		headers = {
			["x-api-key"] = apiKey,
			["Content-Type"] = "multipart/form-data",
		},
		body = createFormData({
			request = {
				value = request,
				type = "text/plain",
			},
			fileContent = {
				value = imageContent,
				type = "image/png",
			},
		}),
	})

	local body = serde.decode("json", res.body)

	return body.operationId
end

return createDecalAsync
