return [[
local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function createOrUpdateAssetAsync(
	instance: Instance,
	creatorId: number,
	creatorType: Enum.AssetCreatorType,
	existingAssetId: string?
): (string, number)
	if existingAssetId then
		print(`[info] updating asset with ID {existingAssetId}`)

		local _success, versionNumber =
			AssetService:CreateAssetVersionAsync(instance, Enum.AssetType.Model, existingAssetId, {
				CreatorId = creatorId,
				CreatorType = creatorType,
			})

		print(`[info] updated asset to version {versionNumber}`)

		return existingAssetId, versionNumber
	else
		print("[info] creating asset for the first time")

		local _success, assetId = AssetService:CreateAssetAsync(instance, Enum.AssetType.Model, {
			Name = instance.Name,
			CreatorId = creatorId,
			CreatorType = creatorType,
			IsPackage = true,
		})

		print(`[info] created asset with ID {assetId}`)

		return assetId, 1
	end
end

local CREATOR_ID = _G.CREATOR_ID
assert(CREATOR_ID, "_G.CREATOR_ID must be supplied")

local creatorId = assert(tonumber(CREATOR_ID), "_G.CREATOR_ID must be an int")

local CREATOR_TYPE = _G.CREATOR_TYPE
assert(CREATOR_TYPE, "_G.CREATOR_TYPE must be supplied")

local creatorType = assert(
	Enum.AssetCreatorType[CREATOR_TYPE],
	"_G.CREATOR_TYPE must be a valid AssetCreatorType value"
)

local ASSET_ID: string? = _G.ASSET_ID

local instance = ReplicatedStorage:GetChildren()[1]
assert(instance, `no instance found for upload in ReplicatedStorage`)

local remoteAssetId, versionNumber = createOrUpdateAssetAsync(instance, creatorId, creatorType, ASSET_ID)

print(`ASSET_ID={remoteAssetId}`)
print(`VERSION_NUMBER={versionNumber}`)
]]
