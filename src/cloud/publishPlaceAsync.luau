local fs = require("@lune/fs")
local serde = require("@lune/serde")

local fetch = require("@root/requests/fetch")
local logging = require("@root/logging")
local types = require("@root/types")

type AssetId = types.AssetId

local function publishPlaceAsync(
	placePath: string,
	universeId: AssetId,
	placeId: AssetId,
	apiKey: string,
	shouldPublish: boolean?
)
	logging.debug("uploading place to Roblox")

	local versionType = if shouldPublish then "Published" else "Saved"

	local res =
		fetch(`https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType={versionType}`, {
			method = "POST",
			body = fs.readFile(placePath),
			headers = {
				["x-api-key"] = apiKey,
				["Content-Type"] = "application/xml",
				["Accept"] = "application/json",
			},
		})

	if res.ok then
		local body = serde.decode("json", res.body)
		return body.versionNumber
	end
end

return publishPlaceAsync
