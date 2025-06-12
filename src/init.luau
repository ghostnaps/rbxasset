local types = require("@self/types")

export type AssetConfig = types.AssetConfig
export type AssetManifest = types.AssetManifest

return {
	publishPackageAsync = require("@self/requests/publishPackageAsync"),
}
