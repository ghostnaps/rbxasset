local fs = require("@lune/fs")
local serde = require("@lune/serde")

local constants = require("@root/constants")
local logging = require("@root/logging")
local types = require("@root/types")

type AssetConfig = types.AssetConfig

local function readAssetConfig(packagePath: string): AssetConfig
	local assetConfigPath = `{packagePath}/{constants.ASSET_CONFIG_FILENAME}`
	local content: string
	local success, err = pcall(function()
		content = fs.readFile(assetConfigPath)
	end)
	assert(success, `failed to read asset config at {assetConfigPath}: {err}`)

	local parsedContent = serde.decode("toml", content)

	local isConfigValid, message = types.validateAssetConfig(parsedContent)
	assert(isConfigValid, `failed to parse asset config at {assetConfigPath}: {message}`)

	logging.debug("loaded asset config", parsedContent)

	return parsedContent :: AssetConfig
end

return readAssetConfig
