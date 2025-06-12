local serde = require("@lune/serde")

local maybeReadAssetManifest = require("@root/maybeReadAssetManifest")
local run = require("@root/lib/run")
local types = require("@root/types")
local waitForOperationAsync = require("@root/waitForOperationAsync")

type AssetConfig = types.AssetConfig

local function setAssetIconAsync(projectPath: string, assetConfig: AssetConfig, apiKey: string)
	if not assetConfig.asset.icon then
		print("[debug] no icon in the asset config. skipping...")
		return
	end

	local assetManifest = maybeReadAssetManifest(projectPath)
	if not assetManifest then
		print("[err] asset manifest must exist before the icon can be set")
		return
	end

	local assetId = assetManifest.assetId
	if not assetId then
		print("[err] no assetId found in the manifest. has the package been uploaded before?")
		return
	end

	local iconImage = if assetManifest.images then assetManifest.images[assetConfig.asset.icon] else nil
	if not iconImage then
		print(`[err] no image found for {assetConfig.asset.icon} in the manifest`)
		return
	end

	local request = serde.encode("json", {
		assetId = assetId,
		icon = `assets/{iconImage.assetId}`,
	})

	local output = run("curl", {
		"--location",
		"--request",
		"PATCH",
		`https://apis.roblox.com/assets/v1/assets/{assetId}?updateMask=icon`,
		"--header",
		`'x-api-key: {apiKey}'`,
		"--form",
		`'request={request}'`,
	})

	local operationId = serde.decode("json", output).operationId

	if not operationId then
		print(`[err] failed to set asset icon`)
		return
	end

	local body = waitForOperationAsync(operationId, apiKey)

	if body.error then
		local problems = {}
		for _, err in body.metadata.errors do
			table.insert(problems, err.error.message)
		end
		print(`[err] failed to set asset icon: {table.concat(problems, ", ")}`)
		return
	end

	print(`[info] icon uploaded successfully`)
end

return setAssetIconAsync
