local process = require("@lune/process")

local logging = require("@root/logging")
local publishAssetAsync = require("@root/requests/publishAssetAsync")
local publishImagesAsync = require("@root/requests/publishImagesAsync")
local readConfig = require("@root/manifest/readConfig")
local setAssetIconAsync = require("@root/requests/setAssetIconAsync")

local function publishPackageAsync(projectPath: string, assetName: string, assetPath: string, apiKey: string)
	local config = readConfig(projectPath)

	local asset = config.assets[assetName]
	if not asset then
		logging.err(`publishing failed, could not find an asset named {assetName} in the config`)
		process.exit(1)
	end

	local environment = config.environments[asset.environment]

	local assetId = publishAssetAsync(projectPath, assetName, asset, environment, assetPath, apiKey)
	publishImagesAsync(projectPath, asset, environment, apiKey)
	setAssetIconAsync(projectPath, assetName, asset, apiKey)

	logging.info("package published successfully! View it on the Creator Store:")
	logging.info(`https://create.roblox.com/store/asset/{assetId}`)
end

return publishPackageAsync
