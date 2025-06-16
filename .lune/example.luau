local fs = require("@lune/fs")
local process = require("@lune/process")

local logging = require("@root/logging")
local rbxasset = require("@root/")

local projectPath = process.args[1]
if typeof(projectPath) ~= "string" and not fs.isDir(projectPath) then
	logging.err(
		`argument #1 must be a path to one of the example projects ('examples/package' or similar expected, got {projectPath})`
	)
	process.exit(1)
end
local absProjectPath = `{process.cwd}/{projectPath}`

local apiKey = process.args[2]
if typeof(apiKey) ~= "string" then
	logging.err(`argument #2 must be an Open Cloud API key (string expected, got {typeof(apiKey)})`)
	process.exit(1)
end

local assetPath = `{process.cwd}asset.rbxm`

logging.info("building project...")
local result = process.exec("rojo", {
	"build",
	`{absProjectPath}/default.project.json`,
	"-o",
	assetPath,
})
assert(result.ok, `process completed with non-zero exit code {result.stderr}`)
logging.info(`built project to {assetPath}`)

rbxasset.publishPackageAsync(absProjectPath, assetPath, apiKey)
