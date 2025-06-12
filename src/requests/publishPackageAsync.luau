local process = require("@lune/process")

local publishAssetAsync = require("@root/requests/publishAssetAsync")
local publishImagesAsync = require("@root/requests/publishImagesAsync")
local readAssetConfig = require("@root/manifest/readAssetConfig")
local setAssetIconAsync = require("@root/requests/setAssetIconAsync")
local types = require("@root/types")

type AssetConfig = types.AssetConfig

local function publishPackageAsync(projectPath: string, assetPath: string, apiKey: string)
	local assetConfig = readAssetConfig(projectPath)

	if not assetConfig.asset.distribute then
		print("[err] refusing to publish because `distribute` is set to `false`")
		process.exit(1)
	end

	local assetId = publishAssetAsync(projectPath, assetConfig, assetPath, apiKey)
	publishImagesAsync(projectPath, assetConfig, apiKey)
	setAssetIconAsync(projectPath, assetConfig, apiKey)

	print("[info] package published successfully! View it on the Creator Store:")
	print(`[info] https://create.roblox.com/store/asset/{assetId}`)
end

return publishPackageAsync
