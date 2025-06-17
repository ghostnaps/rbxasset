local t = require("@pkg/t/lib")

local types = {}

export type AssetType = "Package" | "Plugin"
export type CreatorType = "User" | "Group"
export type AssetId = string | number

export type AssetConfig = {
	asset: {
		name: string,

		description: string?,
		distribute: boolean?,
		icon: string?,
		thumbnails: { string }?,
		type: AssetType,
	},
	deployment: {
		creatorId: number,
		creatorType: CreatorType,
		universeId: number,
		placeId: number,
	},
}
types.validateAssetConfig = t.strictInterface({
	asset = t.strictInterface({
		name = t.string,

		description = t.optional(t.string),
		distribute = t.optional(t.boolean),
		icon = t.optional(t.string),
		thumbnails = t.optional(t.array(t.string)),
		type = t.optional(t.union(t.literal("Package"), t.literal("Plugin"))),
	}),
	deployment = t.strictInterface({
		creatorId = t.union(t.string, t.number),
		creatorType = t.union(t.literal("User"), t.literal("Group")),
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

export type ErrorStatusResponse = {
	code: string,
	message: string,
}

type BaseOperationResponse = {
	done: boolean,
	operationId: string,
	path: string,
}

type OperationPendingResponse = BaseOperationResponse & {
	done: false,
}

type OperationSuccessResponse = BaseOperationResponse & {
	done: true,
	response: { [string]: any },
}

export type OperationResponse = OperationSuccessResponse | OperationPendingResponse | ErrorStatusResponse

return types
