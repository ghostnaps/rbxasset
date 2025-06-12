local net = require("@lune/net")
local serde = require("@lune/serde")
local task = require("@lune/task")

local MAX_ATTEMPTS = 5

local function waitForOperationAsync(operationId: string, apiKey: string)
	local attempts = 0

	while true do
		local res = net.request({
			method = "GET",
			url = `https://apis.roblox.com/assets/v1/operations/{operationId}`,
			headers = {
				["x-api-key"] = apiKey,
			},
		})

		local body = serde.decode("json", res.body)

		attempts += 1

		if body.done then
			return body
		else
			if attempts >= MAX_ATTEMPTS then
				error(`operation "{operationId}" did not complete within MAX_ATTEMPTS attempts`)
			end
			task.wait(1)
		end
	end
end

return waitForOperationAsync
