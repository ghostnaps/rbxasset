export type AssetConfig = {
	name: string,
	description: string?,
	icon: string?,
	thumbnails: { string }?,
	private: boolean?,
}

type Image = {
	assetId: string,
	hash: string,
}

export type AssetManifest = {
	assetId: string,
	images: { [string]: Image }?,
}

return nil
