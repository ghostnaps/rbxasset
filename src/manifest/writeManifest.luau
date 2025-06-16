local fs = require("@lune/fs")
local serde = require("@lune/serde")

local constants = require("@root/constants")
local logging = require("@root/logging")
local types = require("@root/types")

type AssetManifest = types.Manifest

local function writeManifest(packagePath: string, assetManifest: AssetManifest)
	local assetManifestPath = `{packagePath}/{constants.ASSET_MANIFEST_FILENAME}`
	fs.writeFile(assetManifestPath, serde.encode("toml", assetManifest))

	logging.debug(`wrote asset manifest {assetManifestPath}`)
end

return writeManifest
