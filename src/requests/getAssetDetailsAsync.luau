local net = require("@lune/net")
local serde = require("@lune/serde")

local function getAssetDetailsAsync(assetId: string, apiKey: string)
	local res = net.request({
		url = `https://apis.roblox.com/assets/v1/assets/{assetId}`,
		method = "GET",
		headers = {
			["x-api-key"] = apiKey,
			["Content-Type"] = "application/json",
		},
	})

	return serde.decode("json", res.body)
end

return getAssetDetailsAsync
