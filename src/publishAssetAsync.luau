local getAssetDetailsAsync = require("@root/getAssetDetailsAsync")
local maybeReadAssetManifest = require("@root/maybeReadAssetManifest")
local publishAssetTask = require("@root/tasks/publishAsset")
local runLuauTask = require("@root/lib/runLuauTask")
local setAssetDetailsAsync = require("@root/setAssetDetailsAsync")
local types = require("@root/types")
local writeAssetManifest = require("@root/writeAssetManifest")

type AssetConfig = types.AssetConfig

local function publishAssetAsync(
	projectPath: string,
	assetConfig: AssetConfig,
	assetPath: string,
	apiKey: string
): string
	local assetManifest = maybeReadAssetManifest(projectPath)

	-- If this assetId exists then `publish-asset` will update the asset
	-- version. Otherwise it will create the asset for the first time
	local existingAssetId = if assetManifest then assetManifest.assetId else nil

	local assetDetails = if existingAssetId then getAssetDetailsAsync(existingAssetId, apiKey) else nil

	local output = runLuauTask(publishAssetTask, {
		CREATOR_ID = assetConfig.creator.creatorId,
		CREATOR_TYPE = assetConfig.creator.creatorType,

		-- Only provide the assetId from the manifest if there's a matching
		-- asset on the Creator Store. We need this check in case the manifest
		-- is edited manually to a nonexistent id
		ASSET_ID = if assetDetails.assetId then existingAssetId else nil :: any,
	}, {
		universeId = assetConfig.tasks.universeId,
		placeId = assetConfig.tasks.placeId,
		modelPath = assetPath,
		apiKey = apiKey,
	})

	local assetId = output.ASSET_ID

	if assetId then
		-- CreateAssetAsync and CreateAssetVersionAsync in the Luau task
		-- don't actually update the asset's name/description, so we need to
		-- handle that manually.
		setAssetDetailsAsync(assetId, apiKey, {
			displayName = assetConfig.asset.name,
			description = assetConfig.asset.description,
		})

		local newAssetManifest = table.clone(assetManifest or {})
		newAssetManifest.assetId = assetId

		writeAssetManifest(projectPath, newAssetManifest)
	end

	return assetId
end

return publishAssetAsync
