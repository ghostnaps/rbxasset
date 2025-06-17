local fs = require("@lune/fs")
local serde = require("@lune/serde")

local executeLuauTask = require("@root/cloud/executeLuauTask")
local logging = require("@root/logging")
local run = require("@root/lib/run")

local TEMP_DIR = "temp"
local ROJO_PROJECT_PATH = `{TEMP_DIR}/default.project.json`
local BUILD_PATH = `{TEMP_DIR}/build.rbxl`

local function runLuauTask(
	scriptContent: string,
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

	logging.info("creating Rojo project")
	local rojoProject = {
		name = "Build",
		tree = {
			["$className"] = "DataModel",
			ReplicatedStorage = {
				Build = if runnerContext.modelPath
					then {
						-- TODO: Find a better way to reference the path to the asset
						["$path"] = `../{runnerContext.modelPath}`,
					}
					else nil,
			},
		},
	}
	fs.writeFile(ROJO_PROJECT_PATH, serde.encode("json", rojoProject))

	run("rojo", { "build", ROJO_PROJECT_PATH, "-o", BUILD_PATH })

	logging.info("substituting globals", globals)

	for global, value in globals do
		scriptContent = scriptContent:gsub(`= _G.{global}`, `= "{value}"`)
	end

	local variables = executeLuauTask(
		BUILD_PATH,
		scriptContent,
		runnerContext.universeId,
		runnerContext.placeId,
		runnerContext.apiKey
	)

	run("rm", { "-rf", TEMP_DIR })

	return variables
end

return runLuauTask
