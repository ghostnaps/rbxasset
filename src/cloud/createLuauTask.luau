local serde = require("@lune/serde")

local fetch = require("@root/requests/fetch")
local types = require("@root/types")

type AssetId = types.AssetId

type LuauTaskResponse = {
	binaryInput: string,
	binaryOutputUri: string,
	createTime: string,
	enableBinaryOutput: boolean,
	output: {
		results: { any },
	},
	path: string,
	script: string,
	state: string,
	updateTime: string,
	user: string,
	error: { [string]: any }?,
}

local function createLuauTask(
	scriptContent: string,
	universeId: AssetId,
	placeId: AssetId,
	apiKey: string
): LuauTaskResponse
	local res =
		fetch(`https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}/luau-execution-session-tasks`, {
			method = "POST",
			headers = {
				["Content-Type"] = "application/json",
				["x-api-key"] = apiKey,
			},
			body = serde.encode("json", {
				["script"] = scriptContent,
			}),
		})

	return serde.decode("json", res.body)
end

return createLuauTask
