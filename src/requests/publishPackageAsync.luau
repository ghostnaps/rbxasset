local process = require("@lune/process")

local logging = require("@root/logging")
local publishAssetAsync = require("@root/requests/publishAssetAsync")
local publishImagesAsync = require("@root/requests/publishImagesAsync")
local readAssetConfig = require("@root/manifest/readAssetConfig")
local setAssetIconAsync = require("@root/requests/setAssetIconAsync")
local types = require("@root/types")

type AssetConfig = types.AssetConfig

local function publishPackageAsync(projectPath: string, assetPath: string, apiKey: string)
	local assetConfig = readAssetConfig(projectPath)

	if not assetConfig.asset.distribute then
		logging.err("refusing to publish because `distribute` is set to `false`")
		process.exit(1)
	end

	local assetId = publishAssetAsync(projectPath, assetConfig, assetPath, apiKey)
	publishImagesAsync(projectPath, assetConfig, apiKey)
	setAssetIconAsync(projectPath, assetConfig, apiKey)

	logging.info("package published successfully! View it on the Creator Store:")
	logging.info(`https://create.roblox.com/store/asset/{assetId}`)
end

return publishPackageAsync
