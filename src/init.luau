local types = require("@self/types")

export type AssetConfig = types.AssetConfig
export type AssetManifest = types.AssetManifest

return {
	createDecalAsync = require("@self/createDecalAsync"),
	getAssetDetailsAsync = require("@self/getAssetDetailsAsync"),
	maybeReadAssetManifest = require("@self/maybeReadAssetManifest"),
	readAssetConfig = require("@self/readAssetConfig"),
	setAssetDetailsAsync = require("@self/setAssetDetailsAsync"),
	waitForOperationAsync = require("@self/waitForOperationAsync"),
	writeAssetManifest = require("@self/writeAssetManifest"),
}
