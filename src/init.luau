local types = require("@self/types")

export type AssetConfig = types.AssetConfig
export type AssetManifest = types.AssetManifest

return {
	readAssetConfig = require("@self/readAssetConfig"),
	writeAssetManifest = require("@self/writeAssetManifest"),
	maybeReadAssetManifest = require("@self/maybeReadAssetManifest"),

	publishPackageAsync = require("@self/publishPackageAsync"),
}
