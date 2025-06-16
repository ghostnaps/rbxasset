local fs = require("@lune/fs")
local serde = require("@lune/serde")

local constants = require("@root/constants")
local logging = require("@root/logging")
local types = require("@root/types")

type Manifest = types.Manifest

local function maybeReadManifest(packagePath: string): Manifest?
	local manifestPath = `{packagePath}/{constants.ASSET_MANIFEST_FILENAME}`
	local content: string
	local success = pcall(function()
		content = fs.readFile(manifestPath)
	end)

	-- It's expected that the manifest won't exist in certain situations, like
	-- on the first upload of the asset. So we just early exit here
	if not success then
		logging.debug("no asset manifest found")
		return nil
	end

	logging.debug(`found asset manifest at {manifestPath}`)

	local parsedContent = serde.decode("toml", content)

	local isManifestValid, message = types.validateManifest(parsedContent)
	assert(isManifestValid, `failed to parse asset manifest at {manifestPath}: {message}`)

	return parsedContent :: Manifest
end

return maybeReadManifest
