local fs = require("@lune/fs")
local serde = require("@lune/serde")

local constants = require("./constants")
local types = require("./types")

type AssetManifest = types.AssetManifest

local function writeAssetManifest(packagePath: string, assetManifest: AssetManifest)
	local assetManifestPath = `{packagePath}/{constants.ASSET_MANIFEST_FILENAME}`
	fs.writeFile(assetManifestPath, serde.encode("toml", assetManifest))

	print(`[debug] wrote asset manifest {assetManifestPath}`)
end

return writeAssetManifest
