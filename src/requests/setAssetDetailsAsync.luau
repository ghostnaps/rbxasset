local net = require("@lune/net")
local serde = require("@lune/serde")

local createFormData = require("@root/requests/forms/createFormData")
local waitForOperationAsync = require("@root/requests/waitForOperationAsync")

type AssetDetails = {
	displayName: string,
	description: string?,
}

local function setAssetDetailsAsync(assetId: string, apiKey: string, details: AssetDetails)
	local request = serde.encode("json", {
		assetId = assetId,
		displayName = details.displayName,
		description = details.description,
	})

	local formData = createFormData({
		request = {
			value = request,
			contentType = "application/json",
		},
	})

	local res = net.request({
		url = `https://apis.roblox.com/assets/v1/assets/{assetId}?updateMask=description,displayName`,
		method = "PATCH",
		headers = {
			["x-api-key"] = apiKey,
			["Content-Type"] = `multipart/form-data; boundary={formData.boundary}`,
		},
		body = formData.body,
	})

	local body = serde.decode("json", res.body)

	waitForOperationAsync(body.path, apiKey, "https://apis.roblox.com/assets/v1")
end

return setAssetDetailsAsync
