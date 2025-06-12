local fs = require("@lune/fs")
local serde = require("@lune/serde")

local createDecalAsync = require("@root/createDecalAsync")
local extractImageIdsFromDecalsTask = require("@root/tasks/extractImageIdsFromDecals")
local maybeReadAssetManifest = require("@root/maybeReadAssetManifest")
local runLuauTask = require("@root/lib/runLuauTask")
local types = require("@root/types")
local waitForOperationAsync = require("@root/waitForOperationAsync")
local writeAssetManifest = require("@root/writeAssetManifest")

type AssetConfig = types.AssetConfig

type PendingDecal = {
	path: string,
	filename: string,
	decalId: string,
}

local function publishImagesAsync(projectPath: string, assetConfig: AssetConfig, apiKey: string)
	local assetManifest = maybeReadAssetManifest(projectPath)
	local pendingDecals: { PendingDecal } = {}

	local existingImages = if assetManifest
		then assetManifest.images
		else {} :: typeof(({} :: types.AssetManifest).images)

	local icon = assetConfig.asset.icon
	if icon then
		local iconPath = `{projectPath}/{icon}`

		print(`[info] syncing package icon at {iconPath}`)

		local iconHash = serde.hash("sha256", fs.readFile(iconPath))

		if existingImages and existingImages[icon] and existingImages[icon].hash == iconHash then
			print(`[debug] hashes match for {iconPath}, skipping...`)
		else
			print(`[info] uploading decal for image at {iconPath}...`)

			local operationId = createDecalAsync(
				`{assetConfig.asset.name} - Icon`,
				iconPath,
				assetConfig.deployment.creatorId,
				assetConfig.deployment.creatorType,
				apiKey
			)

			if operationId then
				local body = waitForOperationAsync(operationId, apiKey)
				local decalId = body.response.assetId

				table.insert(pendingDecals, {
					path = iconPath,
					filename = icon,
					decalId = decalId,
				})

				print(`[debug] decal uploaded successfully`)
			else
				print(`[warn] failed to upload decal at {iconPath}`)
			end
		end
	end

	local thumbnails = assetConfig.asset.thumbnails
	if thumbnails then
		print("[info] syncing package thumbnails...")

		for index, thumbnailFilename in thumbnails do
			local thumbnailPath = `{projectPath}/{thumbnailFilename}`
			local thumbnailHash = serde.hash("sha256", fs.readFile(thumbnailPath))

			local existingThumbnail = existingImages and existingImages[thumbnailFilename]
			if existingThumbnail and existingThumbnail.hash == thumbnailHash then
				print(`[debug] hashes match for {thumbnailPath}, skipping...`)
				continue
			end

			print(`[info] uploading decal for image at {thumbnailPath}`)

			local operationId = createDecalAsync(
				`{assetConfig.asset.name} - Thumbnail {index}`,
				thumbnailPath,
				assetConfig.deployment.creatorId,
				assetConfig.deployment.creatorType,
				apiKey
			)

			if operationId then
				local body = waitForOperationAsync(operationId, apiKey)
				local decalId = body.response.assetId

				table.insert(pendingDecals, {
					path = thumbnailPath,
					filename = thumbnailFilename,
					decalId = decalId,
				})

				print(`[debug] decal uploaded successfully`)
			else
				print(`[warn] failed to upload decal at {thumbnailPath}`)
			end
		end
	end

	if #pendingDecals > 0 then
		local decalIds: { string } = {}
		for _, pendingDecal in pendingDecals do
			table.insert(decalIds, pendingDecal.decalId)
		end

		local output = runLuauTask(extractImageIdsFromDecalsTask, {
			DECAL_IDS = table.concat(decalIds, ","),
		}, {
			universeId = assetConfig.deployment.universeId,
			placeId = assetConfig.deployment.placeId,
			apiKey = apiKey,
		})

		local imageIds = output.IMAGE_IDS:split(",")

		local newAssetManifest = table.clone(assetManifest or {})
		newAssetManifest.images = newAssetManifest.images or {}

		for index, imageId in imageIds do
			local pendingDecal = pendingDecals[index]

			if pendingDecal then
				newAssetManifest.images[pendingDecal.filename] = {
					assetId = imageId,
					hash = serde.hash("sha256", fs.readFile(pendingDecal.path)),
				}

				print(
					`[debug] image {pendingDecal.path} uploaded successfully: https://create.roblox.com/store/asset/{imageId}`
				)
			else
				print(`[warn] could not map imageId {imageId} back to a pending decal at index {index}`)
			end
		end

		writeAssetManifest(projectPath, newAssetManifest)
	else
		print(`[debug] no new decals to extract images from. skipping...`)
	end

	print("[info] successfully synced images to Creator Store")
end

return publishImagesAsync
