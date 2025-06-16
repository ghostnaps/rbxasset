local fs = require("@lune/fs")
local serde = require("@lune/serde")

local constants = require("@root/constants")
local logging = require("@root/logging")
local types = require("@root/types")

type Config = types.Config

local function readConfig(packagePath: string): Config
	local configPath = `{packagePath}/{constants.ASSET_CONFIG_FILENAME}`
	local content: string
	local success, err = pcall(function()
		content = fs.readFile(configPath)
	end)
	assert(success, `failed to read asset config at {configPath}: {err}`)

	local parsedContent = serde.decode("toml", content)

	local isConfigValid, message = types.validateConfig(parsedContent)
	assert(isConfigValid, `failed to parse asset config at {configPath}: {message}`)

	logging.debug("loaded asset config", parsedContent)

	return parsedContent :: Config
end

return readConfig
