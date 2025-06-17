local getAssetDetailsAsync = require("@root/requests/getAssetDetailsAsync")
local getOrCreateAssetManifest = require("@root/manifest/getOrCreateAssetManifest")
local join = require("@root/lib/join")
local publishAssetTask = require("@root/tasks/publishAsset")
local runLuauTask = require("@root/lib/runLuauTask")
local setAssetDetailsAsync = require("@root/requests/setAssetDetailsAsync")
local types = require("@root/types")
local writeManifest = require("@root/manifest/writeManifest")

type AssetConfig = types.AssetConfig
type EnvironmentConfig = types.EnvironmentConfig

local function publishAssetAsync(
	projectPath: string,
	assetName: string,
	asset: AssetConfig,
	environment: EnvironmentConfig,
	apiKey: string
): string?
	local manifest = getOrCreateAssetManifest(projectPath)
	local existingAsset = manifest.assets[assetName]

	-- If this assetId exists then `tasks/publishAsset` will update the asset
	-- version. Otherwise it will create the asset for the first time
	local existingAssetId = if existingAsset then existingAsset.assetId else nil
	local assetDetails = if existingAssetId then getAssetDetailsAsync(existingAssetId, apiKey) else nil

	local variables = runLuauTask(publishAssetTask, {
		CREATOR_ID = environment.creatorId,
		CREATOR_TYPE = environment.creatorType,

		-- Only provide the assetId from the manifest if there's a matching
		-- asset on the Creator Store. We need this check in case the manifest
		-- is edited manually to a nonexistent id
		ASSET_ID = if assetDetails and assetDetails.assetId then existingAssetId else nil :: any,
	}, {
		universeId = environment.universeId,
		placeId = environment.placeId,
		modelPath = asset.model,
		apiKey = apiKey,
	})

	local assetId = if variables then variables.ASSET_ID else nil

	if assetId then
		-- CreateAssetAsync and CreateAssetVersionAsync in the Luau task
		-- don't actually update the asset's name/description, so we need to
		-- handle that manually.
		setAssetDetailsAsync(assetId, apiKey, {
			displayName = asset.name,
			description = asset.description,
		})

		local newManifest = join(manifest, {
			assets = join(manifest.assets, {
				[assetName] = join(manifest.assets[assetName], {
					assetId = assetId,
				}),
			}),
		})

		writeManifest(projectPath, newManifest)
	end

	return assetId
end

return publishAssetAsync
