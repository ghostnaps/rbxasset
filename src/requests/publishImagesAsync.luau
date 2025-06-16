local fs = require("@lune/fs")
local serde = require("@lune/serde")

local createImageAsync = require("@root/requests/createImageAsync")
local logging = require("@root/logging")
local maybeReadManifest = require("@root/manifest/maybeReadManifest")
local types = require("@root/types")
local writeManifest = require("@root/manifest/writeManifest")

type AssetConfig = types.AssetConfig
type EnvironmentConfig = types.EnvironmentConfig

type PendingImage = {
	path: string,
	filename: string,
	assetId: string,
}

local function publishImagesAsync(
	projectPath: string,
	assetConfig: AssetConfig,
	environment: EnvironmentConfig,
	apiKey: string
)
	local assetManifest = maybeReadManifest(projectPath)
	local pendingImages: { PendingImage } = {}

	local existingImages = if assetManifest then assetManifest.images else {} :: typeof(({} :: types.Manifest).images)

	local icon = assetConfig.icon
	if icon then
		local iconPath = `{projectPath}/{icon}`

		logging.info(`syncing package icon at {iconPath}`)

		local iconHash = serde.hash("sha256", fs.readFile(iconPath))

		if existingImages and existingImages[icon] and existingImages[icon].hash == iconHash then
			logging.debug(`hashes match for {iconPath}, skipping...`)
		else
			logging.info(`uploading image at {iconPath}...`)

			local operation = createImageAsync(
				`{assetConfig.name} - Icon`,
				iconPath,
				environment.creatorId,
				environment.creatorType,
				apiKey
			)

			local assetId = operation.response.assetId

			if assetId then
				table.insert(pendingImages, {
					path = iconPath,
					filename = icon,
					assetId = assetId,
				})

				logging.debug(`image uploaded successfully`)
			else
				logging.warn(`failed to upload image at {iconPath}`)
			end
		end
	end

	local thumbnails = assetConfig.thumbnails
	if thumbnails then
		logging.info("syncing package thumbnails...")

		for index, thumbnailFilename in thumbnails do
			local thumbnailPath = `{projectPath}/{thumbnailFilename}`
			local thumbnailHash = serde.hash("sha256", fs.readFile(thumbnailPath))

			local existingThumbnail = existingImages and existingImages[thumbnailFilename]
			if existingThumbnail and existingThumbnail.hash == thumbnailHash then
				logging.debug(`hashes match for {thumbnailPath}, skipping...`)
				continue
			end

			logging.info(`uploading image at {thumbnailPath}`)

			local operation = createImageAsync(
				`{assetConfig.name} - Thumbnail {index}`,
				thumbnailPath,
				environment.creatorId,
				environment.creatorType,
				apiKey
			)

			local assetId = operation.response.assetId

			if assetId then
				table.insert(pendingImages, {
					path = thumbnailPath,
					filename = thumbnailFilename,
					assetId = assetId,
				})

				logging.debug(`image uploaded successfully`)
			else
				logging.warn(`failed to upload image at {thumbnailPath}`)
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

			logging.debug(
				`image {pendingImage.path} uploaded successfully: https://create.roblox.com/store/asset/{pendingImage.assetId}`
			)
		end

		writeManifest(projectPath, newAssetManifest)
	else
		logging.debug("no new images to write to the manifest. skipping...")
	end

	logging.info("successfully synced images to Creator Store")
end

return publishImagesAsync
