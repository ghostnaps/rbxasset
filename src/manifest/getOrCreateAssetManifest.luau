local fs = require("@lune/fs")
local serde = require("@lune/serde")

local constants = require("@root/constants")
local join = require("@root/lib/join")
local logging = require("@root/logging")
local types = require("@root/types")

type Manifest = types.Manifest

local function getOrCreateAssetManifest(packagePath: string): Manifest
	local manifestPath = `{packagePath}/{constants.ASSET_MANIFEST_FILENAME}`
	local content: string
	local success = pcall(function()
		content = fs.readFile(manifestPath)
	end)

	-- It's expected that the manifest won't exist in certain situations, like
	-- on the first upload of the asset. So we just early exit here

	local parsedManifest = if success then serde.decode("toml", content) else nil
	local manifest: Manifest = join({
		assets = {},
		images = {},
	}, parsedManifest)

	local isManifestValid, message = types.validateManifest(manifest)
	assert(isManifestValid, `failed to parse asset manifest at {manifestPath}: {message}`)

	logging.debug(`loaded asset manifest {manifest}`)

	return manifest
end

return getOrCreateAssetManifest
