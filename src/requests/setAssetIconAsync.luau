local net = require("@lune/net")
local serde = require("@lune/serde")

local createFormData = require("@root/requests/forms/createFormData")
local logging = require("@root/logging")
local maybeReadAssetManifest = require("@root/manifest/maybeReadAssetManifest")
local types = require("@root/types")
local waitForAssetOperationAsync = require("@root/requests/waitForAssetOperationAsync")

type AssetConfig = types.AssetConfig

local ASSETS_BASE_URL = "https://apis.roblox.com/assets/v1"

local function setAssetIconAsync(projectPath: string, assetConfig: AssetConfig, apiKey: string)
	if not assetConfig.asset.icon then
		logging.debug("no icon in the asset config. skipping...")
		return
	end

	local assetManifest = maybeReadAssetManifest(projectPath)
	if not assetManifest then
		logging.err("asset manifest must exist before the icon can be set")
		return
	end

	local assetId = assetManifest.assetId
	if not assetId then
		logging.err("no assetId found in the manifest. has the package been uploaded before?")
		return
	end

	local iconImage = if assetManifest.images then assetManifest.images[assetConfig.asset.icon] else nil
	if not iconImage then
		logging.err(`no image found for {assetConfig.asset.icon} in the manifest`)
		return
	end

	local request = serde.encode("json", {
		assetId = assetId,
		icon = `assets/{iconImage.assetId}`,
	})

	local formData = createFormData({
		request = {
			value = request,
			contentType = "application/json",
		},
	})

	local res = net.request({
		url = `{ASSETS_BASE_URL}/assets/{assetId}?updateMask=icon`,
		method = "PATCH",
		headers = {
			["x-api-key"] = apiKey,
			["Content-Type"] = `multipart/form-data; boundary={formData.boundary}`,
		},
		body = formData.body,
	})

	local body = serde.decode("json", res.body)

	if not body.operationId then
		logging.err(`failed to set asset icon`)
		return
	end

	local operation = waitForAssetOperationAsync(body.operationId, apiKey)

	if operation.message then
		local problems = {}
		for _, err in operation.metadata.errors do
			table.insert(problems, err.error.message)
		end
		logging.err(`failed to set asset icon: {table.concat(problems, ", ")}`)
		return
	end

	logging.info(`icon uploaded successfully`)
end

return setAssetIconAsync
