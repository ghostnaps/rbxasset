return [[
local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function createOrUpdateAssetAsync(
	instance: Instance,
	creatorId: number,
	creatorType: Enum.AssetCreatorType,
	assetType: Enum.AssetType,
	existingAssetId: string?
): (string, number)
	local isPackage = false
	if assetType == Enum.AssetType.Package then
		isPackage = true
		assetType = Enum.AssetType.Model
	end

	if existingAssetId then
		print(`updating asset with ID {existingAssetId}`)

		local _success, versionNumber =
			AssetService:CreateAssetVersionAsync(instance, assetType, existingAssetId, {
				CreatorId = creatorId,
				CreatorType = creatorType,
			})

		print(`updated asset to version {versionNumber}`)

		return existingAssetId, versionNumber
	else
		print("creating asset for the first time")

		local _success, assetId = AssetService:CreateAssetAsync(instance, assetType, {
			Name = instance.Name,
			CreatorId = creatorId,
			CreatorType = creatorType,
			IsPackage = isPackage,
		})

		print(`created asset with ID {assetId}`)

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

local ASSET_TYPE = _G.ASSET_TYPE
assert(ASSET_TYPE, "_G.ASSET_TYPE must be supplied")

local assetType = assert(
	Enum.AssetType[ASSET_TYPE],
	"_G.ASSET_TYPE must be a valid Enum.AssetType value"
)

local ASSET_ID: string? = _G.ASSET_ID

local instance = ReplicatedStorage:GetChildren()[1]
assert(instance, `no instance found for upload in ReplicatedStorage`)

local remoteAssetId, versionNumber = createOrUpdateAssetAsync(instance, creatorId, creatorType, assetType, ASSET_ID)

print(`ASSET_ID={remoteAssetId}`)
print(`VERSION_NUMBER={versionNumber}`)
]]
