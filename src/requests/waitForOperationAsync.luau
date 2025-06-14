local net = require("@lune/net")
local serde = require("@lune/serde")
local task = require("@lune/task")

local CLOUD_OPERATIONS_BASE_URL = `https://apis.roblox.com/cloud/v2`
local MAX_RETRIES = 5
local RETRY_MULTIPLIER = 2

type OperationResponse = {
	done: boolean,
	operationId: string,
	path: string,
	response: { [string]: any },
}

local function waitForOperationAsync(operationPath: string, apiKey: string, baseUrl: string?): OperationResponse
	local currentRetries = 0
	local retryPollingDelay = 1

	local operationsBaseUrl = if baseUrl then baseUrl else CLOUD_OPERATIONS_BASE_URL

	while currentRetries < MAX_RETRIES do
		local res = net.request({
			method = "GET",
			url = `{operationsBaseUrl}/{operationPath}`,
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
	error(`operation "{operationPath}" did not complete within {MAX_RETRIES} attempts`)
end

return waitForOperationAsync
