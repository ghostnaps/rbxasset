local types = require("@self/types")

export type AssetConfig = types.AssetConfig
export type AssetManifest = types.AssetManifest

return {
	readAssetConfig = require("@self/manifest/readAssetConfig"),
	writeAssetManifest = require("@self/manifest/writeAssetManifest"),
	maybeReadAssetManifest = require("@self/manifest/maybeReadAssetManifest"),

	publishPackageAsync = require("@self/requests/publishPackageAsync"),
}
