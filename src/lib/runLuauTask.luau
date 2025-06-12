local fs = require("@lune/fs")
local serde = require("@lune/serde")

local run = require("@root/lib/run")

local TEMP_DIR = "temp"
local TASK_PATH = `{TEMP_DIR}/task.luau`
local ROJO_PROJECT_PATH = `{TEMP_DIR}/default.project.json`
local BUILD_PATH = `{TEMP_DIR}/build.rbxl`

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

	print("[info] creating Rojo project")
	local rojoProject = {
		name = "Build",
		tree = {
			["$className"] = "DataModel",
			ReplicatedStorage = {
				["$path"] = runnerContext.modelPath,
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

	fs.removeDir("temp")

	local result: { [string]: string } = {}
	for key, value in output:gmatch("([%u_]+)=([%d%w]+)") do
		if key and value then
			value = value:gsub("(%s+)?.*(%s+)?", "")
			result[key] = value
		end
	end

	return result
end

return runLuauTask
