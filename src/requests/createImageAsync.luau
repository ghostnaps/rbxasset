local fs = require("@lune/fs")
local net = require("@lune/net")
local serde = require("@lune/serde")

local createFormData = require("@root/requests/forms/createFormData")
local waitForAssetOperationAsync = require("@root/requests/waitForAssetOperationAsync")

local function createImageAsync(
	displayName: string,
	imagePath: string,
	creatorId: number,
	creatorType: "User" | "Group",
	apiKey: string
)
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
			contentType = "application/json",
		},
		fileContent = {
			filename = imagePath:match("[/\\](.+)$"),
			value = fs.readFile(imagePath),
			contentType = "image/png",
		},
	})

	local res = net.request({
		url = "https://apis.roblox.com/assets/v1/assets",
		method = "POST",
		headers = {
			["x-api-key"] = apiKey,
			["Content-Type"] = `multipart/form-data; boundary={formData.boundary}`,
		},
		body = formData.body,
	})

	local body = serde.decode("json", res.body)

	return waitForAssetOperationAsync(body.operationId, apiKey)
end

return createImageAsync
