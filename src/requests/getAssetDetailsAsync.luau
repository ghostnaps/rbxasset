local serde = require("@lune/serde")

local fetch = require("@root/requests/fetch")

local function getAssetDetailsAsync(assetId: string, apiKey: string)
	local res = fetch(`https://apis.roblox.com/assets/v1/assets/{assetId}`, {
		method = "GET",
		headers = {
			["x-api-key"] = apiKey,
			["Content-Type"] = "application/json",
		},
	})

	return serde.decode("json", res.body)
end

return getAssetDetailsAsync
