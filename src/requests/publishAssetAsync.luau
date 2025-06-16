local getAssetDetailsAsync = require("@root/requests/getAssetDetailsAsync")
local maybeReadManifest = require("@root/manifest/maybeReadManifest")
local publishAssetTask = require("@root/tasks/publishAsset")
local runLuauTask = require("@root/lib/runLuauTask")
local setAssetDetailsAsync = require("@root/requests/setAssetDetailsAsync")
local types = require("@root/types")
local writeManifest = require("@root/manifest/writeManifest")

type AssetConfig = types.AssetConfig
type EnvironmentConfig = types.EnvironmentConfig

local function publishAssetAsync(
	projectPath: string,
	asset: AssetConfig,
	environment: EnvironmentConfig,
	assetPath: string,
	apiKey: string
): string
	local assetManifest = maybeReadManifest(projectPath)

	-- If this assetId exists then `publish-asset` will update the asset
	-- version. Otherwise it will create the asset for the first time
	local existingAssetId = if assetManifest then assetManifest.assetId else nil

	local assetDetails = if existingAssetId then getAssetDetailsAsync(existingAssetId, apiKey) else nil

	local output = runLuauTask(publishAssetTask, {
		CREATOR_ID = environment.creatorId,
		CREATOR_TYPE = environment.creatorType,

		-- Only provide the assetId from the manifest if there's a matching
		-- asset on the Creator Store. We need this check in case the manifest
		-- is edited manually to a nonexistent id
		ASSET_ID = if assetDetails and assetDetails.assetId then existingAssetId else nil :: any,
	}, {
		universeId = environment.universeId,
		placeId = environment.placeId,
		modelPath = assetPath,
		apiKey = apiKey,
	})

	local assetId = output.ASSET_ID

	if assetId then
		-- CreateAssetAsync and CreateAssetVersionAsync in the Luau task
		-- don't actually update the asset's name/description, so we need to
		-- handle that manually.
		setAssetDetailsAsync(assetId, apiKey, {
			displayName = asset.name,
			description = asset.description,
		})

		local newAssetManifest = table.clone(assetManifest or {})
		newAssetManifest.assetId = assetId

		writeManifest(projectPath, newAssetManifest)
	end

	return assetId
end

return publishAssetAsync
