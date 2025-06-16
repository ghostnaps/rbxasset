local t = require("@pkg/t/lib")

local types = {}

local function countObject(obj: { [any]: any }): number
	local count = 0
	for _ in obj do
		count += 1
	end
	return count
end

export type AssetConfig = {
	name: string,
	environment: string,

	description: string?,
	icon: string?,
	thumbnails: { string }?,
	distribute: boolean?,
}
types.validateAssetConfig = t.strictInterface({
	name = t.string,
	environment = t.string,

	icon = t.optional(t.string),
	description = t.optional(t.string),
	thumbnails = t.optional(t.array(t.string)),
	distribute = t.optional(t.boolean),
})

export type EnvironmentConfig = {
	creatorId: number,
	creatorType: "User" | "Group",
	universeId: number,
	placeId: number,
}
types.validateEnvironmentConfig = t.strictInterface({
	creatorId = t.union(t.string, t.number),
	creatorType = t.union(t.literal("User"), t.literal("Group")),
	universeId = t.number,
	placeId = t.number,
})

export type Config = {
	assets: {
		[string]: AssetConfig,
	},
	environments: {
		[string]: EnvironmentConfig,
	},
}
types.validateConfig = function(value: any): (boolean, string?)
	local success, message = t.strictInterface({
		assets = t.map(t.string, types.validateAssetConfig),
		environments = t.map(t.string, types.validateEnvironmentConfig),
	})(value)

	if not success then
		return success, message
	end

	if typeof(value.assets) == "table" and countObject(value.assets) == 0 then
		return false, "at least one asset must be defined in the config"
	end

	if typeof(value.environments) == "table" and countObject(value.environments) == 0 then
		return false, "at least one environment must be defined in the config"
	end

	for key, asset in value.assets do
		if not value.environments[asset.environment] then
			return false, `asset "{key}" attempts to use the environment "{asset.environment}" which does not exist`
		end
	end

	return true, nil
end

type Image = {
	assetId: string,
	hash: string,
}

type ManifestEntry = {
	assetId: string,
	images: { [string]: Image }?,
}
types.validateManifestEntry = t.strictInterface({
	assetId = t.string,
	images = t.optional(t.map(
		t.string,
		t.strictInterface({
			assetId = t.string,
			hash = t.string,
		})
	)),
})

export type Manifest = {
	assetId: string,
	images: { [string]: Image }?,
}
types.validateManifest = t.map(t.string, types.validateManifestEntry)

return types
