local t = require("@root/lib/t")

local types = {}

export type AssetConfig = {
	asset: {
		name: string,
		description: string?,
		icon: string?,
		thumbnails: { string }?,
		distribute: boolean?,
	},
	creator: {
		creatorId: number,
		creatorType: "User" | "Group",
	},
	tasks: {
		universeId: number,
		placeId: number,
	},
}
types.validateAssetConfig = t.strictInterface({
	asset = t.strictInterface({
		name = t.string,
		icon = t.optional(t.string),
		description = t.optional(t.string),
		thumbnails = t.optional(t.array(t.string)),
		distribute = t.optional(t.boolean),
	}),
	creator = t.strictInterface({
		creatorId = t.union(t.string, t.number),
		creatorType = t.union(t.literal("User"), t.literal("Group")),
	}),
	tasks = t.strictInterface({
		universeId = t.number,
		placeId = t.number,
	}),
})

type Image = {
	assetId: string,
	hash: string,
}

export type AssetManifest = {
	assetId: string,
	images: { [string]: Image }?,
}
types.validateAssetManifest = t.strictInterface({
	assetId = t.string,
	images = t.optional(t.map(
		t.string,
		t.strictInterface({
			assetId = t.string,
			hash = t.string,
		})
	)),
})

return types
