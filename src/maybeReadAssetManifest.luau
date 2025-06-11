local fs = require("@lune/fs")
local serde = require("@lune/serde")

local assertValueType = require("./validation/assertValueType")
local constants = require("./constants")
local types = require("./types")

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
		print("[debug] no asset manifest found")
		return nil
	end

	print(`[debug] found asset manifest at {assetManifestPath}`)

	local parsedContent = serde.decode("toml", content)

	assertValueType(parsedContent.assetId, "assetId", "string")

	return parsedContent :: AssetManifest
end

return maybeReadAssetManifest
