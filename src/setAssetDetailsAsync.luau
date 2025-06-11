local serde = require("@lune/serde")

local run = require("@root/lib/run")

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

	local output = run("curl", {
		"--location",
		"--request",
		"PATCH",
		`https://apis.roblox.com/assets/v1/assets/{assetId}?updateMask=description,displayName`,
		"--header",
		`'x-api-key: {apiKey}'`,
		"--form",
		`request='{request}'`,
	})

	return serde.decode("json", output)
end

return setAssetDetailsAsync
