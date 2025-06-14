local fs = require("@lune/fs")
local net = require("@lune/net")
local serde = require("@lune/serde")

local logging = require("@root/logging")
local run = require("@root/lib/run")
local waitForOperationAsync = require("@root/requests/waitForOperationAsync")

local TEMP_DIR = "temp"
local TASK_PATH = `{TEMP_DIR}/task.luau`
local ROJO_PROJECT_PATH = `{TEMP_DIR}/default.project.json`
local BUILD_PATH = `{TEMP_DIR}/build.rbxl`

local function extractVariablesFromOutput(output: string)
	local result: { [string]: string } = {}
	for key, value in output:gmatch("([%u_]+)=([%d%w]+)") do
		if key and value then
			value = value:gsub("(%s+)?.*(%s+)?", "")
			result[key] = value
		end
	end

	return result
end

local function runLuauTask(
	taskBody: string,
	globals: {
		[string]: string | number | boolean,
	},
	runnerContext: {
		universeId: number,
		placeId: number,
		apiKey: string,
		modelPath: string?,
	}
)
	run("rm", { "-rf", TEMP_DIR })

	if not fs.isDir("temp") then
		fs.writeDir("temp")
	end
	fs.writeFile(TASK_PATH, taskBody)

	logging.info("creating Rojo project")
	local rojoProject = {
		name = "Build",
		tree = {
			["$className"] = "DataModel",
			ReplicatedStorage = {
				-- TODO: Figure out if there's a clean way to retain the name of
				-- the instance
				Build = if runnerContext.modelPath
					then {
						["$path"] = runnerContext.modelPath,
					}
					else nil,
			},
		},
	}
	fs.writeFile(ROJO_PROJECT_PATH, serde.encode("json", rojoProject))

	run("rojo", { "build", ROJO_PROJECT_PATH, "-o", BUILD_PATH })

	print("[info] substituting globals", globals)

	for global, value in globals do
		run("sed", { "-i", "-e", `'s/= _G.{global}/= "{value}"/g'`, TASK_PATH })
	end

	local output = run("python3", {
		"src/python/upload_and_run_task.py",
		BUILD_PATH,
		TASK_PATH,
	}, {
		env = {
			ROBLOX_CI_UNIVERSE_ID = runnerContext.universeId,
			ROBLOX_CI_PLACE_ID = runnerContext.placeId,
			ROBLOX_API_KEY = runnerContext.apiKey,
		},
	})

	run("rm", { "-rf", TEMP_DIR })

	if runnerContext.modelPath then
		logging.info("checking the children in the place")
		local res = net.request({
			method = "GET",
			url = `https://apis.roblox.com/cloud/v2/universes/{runnerContext.universeId}/places/{runnerContext.placeId}/instances/root:listChildren`,
			headers = {
				["x-api-key"] = runnerContext.apiKey,
			},
		})

		local body = serde.decode("json", res.body)

		print("body", body)

		local operation = waitForOperationAsync(body.path, runnerContext.apiKey)

		print("operation", operation)
	end

	return extractVariablesFromOutput(output)
end

return runLuauTask
