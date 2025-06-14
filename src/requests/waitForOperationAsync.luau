local net = require("@lune/net")
local serde = require("@lune/serde")
local task = require("@lune/task")

local OPERATIONS_BASE_URL = `https://apis.roblox.com/cloud/v2`
local MAX_RETRIES = 10
local RETRY_MULTIPLIER = 2

local function waitForOperationAsync(operationPath: string, apiKey: string)
	local currentRetries = 0
	local retryPollingDelay = 1

	while currentRetries < MAX_RETRIES do
		local res = net.request({
			method = "GET",
			url = `{OPERATIONS_BASE_URL}/{operationPath}`,
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
