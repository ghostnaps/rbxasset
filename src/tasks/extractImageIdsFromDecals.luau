return [[
local InsertService = game:GetService("InsertService")

local function extractImageAssetFromDecals(decalIds: { string }): { string }
	local imageIds: { string } = {}

	for _, decalIdStr in decalIds do
		local decalId = assert(tonumber(decalIdStr), `could not convert {decalIdStr} into a number`)
		print(`[info] loaded asset with ID {decalId}`)
		local asset = InsertService:LoadAsset(decalId)
		local decal = asset:FindFirstChildOfClass("Decal")

		if decal then
			local imageId = decal.Texture:match("(%d+)$")
			assert(imageId, `failed to parse a valid asset ID from string "{decal.Texture}"`)
			print(`[info] extracted Image ID {imageId} from Decal {decalId}`)
			table.insert(imageIds, imageId)
		end
	end

	return imageIds
end

local DECAL_IDS = _G.DECAL_IDS
assert(typeof(DECAL_IDS) == "string", "Luau")

local decalIds = DECAL_IDS:split(",")
local imageIds = extractImageAssetFromDecals(decalIds)

print(`IMAGE_IDS={table.concat(imageIds, ",")}`)
]]
