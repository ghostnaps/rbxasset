local fs = require("@lune/fs")
local serde = require("@lune/serde")

local createImageAsync = require("@root/requests/createImageAsync")
local maybeReadAssetManifest = require("@root/manifest/maybeReadAssetManifest")
local types = require("@root/types")
local waitForOperationAsync = require("@root/requests/waitForOperationAsync")
local writeAssetManifest = require("@root/manifest/writeAssetManifest")

type AssetConfig = types.AssetConfig

type PendingImage = {
	path: string,
	filename: string,
	assetId: string,
}

local function publishImagesAsync(projectPath: string, assetConfig: AssetConfig, apiKey: string)
	local assetManifest = maybeReadAssetManifest(projectPath)
	local pendingImages: { PendingImage } = {}

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
			print(`[info] uploading image at {iconPath}...`)

			local operationId = createImageAsync(
				`{assetConfig.asset.name} - Icon`,
				iconPath,
				assetConfig.deployment.creatorId,
				assetConfig.deployment.creatorType,
				apiKey
			)

			if operationId then
				local body = waitForOperationAsync(operationId, apiKey)
				local assetId = body.response.assetId

				table.insert(pendingImages, {
					path = iconPath,
					filename = icon,
					assetId = assetId,
				})

				print(`[debug] image uploaded successfully`)
			else
				print(`[warn] failed to upload image at {iconPath}`)
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

			print(`[info] uploading image at {thumbnailPath}`)

			local operationId = createImageAsync(
				`{assetConfig.asset.name} - Thumbnail {index}`,
				thumbnailPath,
				assetConfig.deployment.creatorId,
				assetConfig.deployment.creatorType,
				apiKey
			)

			if operationId then
				local body = waitForOperationAsync(operationId, apiKey)
				local assetId = body.response.assetId

				table.insert(pendingImages, {
					path = thumbnailPath,
					filename = thumbnailFilename,
					assetId = assetId,
				})

				print(`[debug] image uploaded successfully`)
			else
				print(`[warn] failed to upload image at {thumbnailPath}`)
			end
		end
	end

	if #pendingImages > 0 then
		local newAssetManifest = table.clone(assetManifest or {})
		newAssetManifest.images = newAssetManifest.images or {}

		for _, pendingImage in pendingImages do
			newAssetManifest.images[pendingImage.filename] = {
				assetId = pendingImage.assetId,
				hash = serde.hash("sha256", fs.readFile(pendingImage.path)),
			}

			print(
				`[debug] image {pendingImage.path} uploaded successfully: https://create.roblox.com/store/asset/{pendingImage.assetId}`
			)
		end

		writeAssetManifest(projectPath, newAssetManifest)
	else
		print("[debug] no new images to write to the manifest. skipping...")
	end

	print("[info] successfully synced images to Creator Store")
end

return publishImagesAsync
