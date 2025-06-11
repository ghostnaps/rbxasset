local serde = require("@lune/serde")

local run = require("@root/lib/run")

local function createDecalAsync(
	displayName: string,
	imagePath: string,
	creatorId: string,
	creatorType: "User" | "Group",
	apiKey: string
): string?
	local creatorIdKey = if creatorType == "User" then "userId" else "groupId"

	local request = serde.encode("json", {
		assetType = "Decal",
		displayName = displayName,
		creationContext = {
			creator = {
				[creatorIdKey] = creatorId,
			},
		},
	})

	local output = run("curl", {
		"--location",
		"https://apis.roblox.com/assets/v1/assets",
		"--header",
		`'x-api-key: {apiKey}'`,
		"--form",
		`request='{request}'`,
		"--form",
		`fileContent=@{imagePath};type=image/png`,
	})
	local res = serde.decode("json", output)

	return res.operationId
end

return createDecalAsync
