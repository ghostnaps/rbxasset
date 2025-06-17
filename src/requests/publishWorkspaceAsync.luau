local task = require("@lune/task")

local logging = require("@root/logging")
local publishAssetAsync = require("@root/requests/publishAssetAsync")
local publishImagesAsync = require("@root/requests/publishImagesAsync")
local readConfig = require("@root/manifest/readConfig")
local setAssetIconAsync = require("@root/requests/setAssetIconAsync")

local function publishWorkspaceAsync(projectPath: string, apiKey: string)
	local config = readConfig(projectPath)

	for assetName, asset in config.assets do
		local environment = config.environments[asset.environment]

		task.spawn(function()
			local assetId = publishAssetAsync(projectPath, assetName, asset, environment, asset.model, apiKey)
			publishImagesAsync(projectPath, asset, environment, apiKey)
			setAssetIconAsync(projectPath, assetName, asset, apiKey)

			logging.info("package published successfully! View it on the Creator Store:")
			logging.info(`https://create.roblox.com/store/asset/{assetId}`)
		end)
	end
end

return publishWorkspaceAsync
