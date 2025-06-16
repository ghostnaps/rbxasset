local net = require("@lune/net")
local serde = require("@lune/serde")
local task = require("@lune/task")

local MAX_RETRIES = 5
local RETRY_MULTIPLIER = 2

type OperationResponse = {
	done: boolean,
	operationId: string,
	path: string,
	response: { [string]: any },
} | {
	code: string,
	message: string,
}

local function waitForAssetOperationAsync(operationId: string, apiKey: string): OperationResponse
	local currentRetries = 0
	local retryPollingDelay = 1

	while currentRetries < MAX_RETRIES do
		local res = net.request({
			url = `https://apis.roblox.com/assets/v1/operations/{operationId}`,
			method = "GET",
			headers = {
				["x-api-key"] = apiKey,
			},
		})

		local body = serde.decode("json", res.body)

		if res.ok and body.done then
			return body
		else
			task.wait(retryPollingDelay)
			retryPollingDelay *= RETRY_MULTIPLIER
		end
	end
	error(`operation "{operationId}" did not complete within {MAX_RETRIES} attempts`)
end

return waitForAssetOperationAsync
