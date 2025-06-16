local serde = require("@lune/serde")

local createFormData = require("@root/requests/forms/createFormData")
local fetch = require("@root/requests/fetch")
local waitForAssetOperationAsync = require("@root/requests/waitForAssetOperationAsync")

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

	local res = fetch(`https://apis.roblox.com/assets/v1/assets/{assetId}?updateMask=description,displayName`, {
		method = "PATCH",
		headers = {
			["x-api-key"] = apiKey,
			["Content-Type"] = `multipart/form-data; boundary={formData.boundary}`,
		},
		body = formData.body,
	})

	local body = serde.decode("json", res.body)

	waitForAssetOperationAsync(body.operationId, apiKey)
end

return setAssetDetailsAsync
