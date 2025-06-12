return [[
local InsertService = game:GetService("InsertService")

local function extractImageAssetFromDecals(decalIds: { string }): { string }
	local imageIds: { string } = {}

	for _, decalId in decalIds do
		local asset = InsertService:LoadAsset(decalId)
		local decal = asset:FindFirstChildOfClass("Decal")

		if decal then
			table.insert(imageIds, decal.Texture:match("(%d+)$"))
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
