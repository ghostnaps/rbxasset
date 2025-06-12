local process = require("@lune/process")

local rbxasset = require("@root/")

local apiKey = process.args[1]
if typeof(apiKey) ~= "string" then
	print(`[err] argument #1 must be an Open Cloud API key (string expected, got {typeof(apiKey)})`)
	process.exit(1)
end

local projectPath = `{process.cwd}examples/package`
local assetPath = `{process.cwd}asset.rbxm`

print("[info] building project...")
local result = process.exec("rojo", {
	"build",
	`{projectPath}/default.project.json`,
	"-o",
	assetPath,
})
assert(result.ok, `process completed with non-zero exit code {result.stderr}`)
print(`[info] built project to {assetPath}`)

rbxasset.publishPackageAsync(projectPath, assetPath, apiKey)
