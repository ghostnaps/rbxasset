local fs = require("@lune/fs")
local serde = require("@lune/serde")

local assertArray = require("./validation/assertArray")
local assertPublicFieldType = require("./validation/assertPublicFieldType")
local assertValueType = require("./validation/assertValueType")
local constants = require("./constants")
local types = require("./types")

type AssetConfig = types.AssetConfig

local function readAssetConfig(packagePath: string): AssetConfig
	local content: string
	local success, err = pcall(function()
		content = fs.readFile(`{packagePath}/{constants.ASSET_CONFIG_FILENAME}`)
	end)

	assert(success, `failed to find {constants.ASSET_CONFIG_FILENAME} at {packagePath}: {err}`)

	local parsedContent = serde.decode("toml", content)

	assertPublicFieldType(parsedContent.name, "name", "string")

	if parsedContent.description then
		assertValueType(parsedContent.description, "description", "string")
	end

	if parsedContent.icon then
		assertValueType(parsedContent.icon, "icon", "string")
	end

	if parsedContent.thumbnails then
		assertArray(parsedContent.thumbnails, "thumbnails", "string")
	end

	if parsedContent.private then
		assertValueType(parsedContent.private, "private", "boolean")
	end

	print("[debug] loaded asset config", parsedContent)

	return parsedContent :: AssetConfig
end

return readAssetConfig
