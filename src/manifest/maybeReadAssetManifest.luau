local fs = require("@lune/fs")
local serde = require("@lune/serde")

local constants = require("@root/constants")
local logging = require("@root/logging")
local types = require("@root/types")

type AssetManifest = types.AssetManifest

local function maybeReadAssetManifest(packagePath: string): AssetManifest?
	local assetManifestPath = `{packagePath}/{constants.ASSET_MANIFEST_FILENAME}`
	local content: string
	local success = pcall(function()
		content = fs.readFile(assetManifestPath)
	end)

	-- It's expected that the manifest won't exist in certain situations, like
	-- on the first upload of the asset. So we just early exit here
	if not success then
		logging.debug("no asset manifest found")
		return nil
	end

	logging.debug(`found asset manifest at {assetManifestPath}`)

	local parsedContent = serde.decode("toml", content)

	local isManifestValid, message = types.validateAssetManifest(parsedContent)
	assert(isManifestValid, `failed to parse asset config at {assetManifestPath}: {message}`)

	return parsedContent :: AssetManifest
end

return maybeReadAssetManifest
