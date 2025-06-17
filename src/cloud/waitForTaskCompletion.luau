local serde = require("@lune/serde")
local task = require("@lune/task")

local fetch = require("@root/requests/fetch")

local function waitForTaskCompletion(operationPath: string, apiKey: string)
	while true do
		local res = fetch(`https://apis.roblox.com/cloud/v2/{operationPath}`, {
			headers = {
				["x-api-key"] = apiKey,
			},
		})

		local luauTask = serde.decode("json", res.body)

		if luauTask.state ~= "PROCESSING" then
			return luauTask
		else
			task.wait(2)
		end
	end
end

return waitForTaskCompletion
