local rbxasset = require("@root/")

local process = require("@lune/process")

local apiKey = process.args[1]

assert(
	process.cwd:match("examples/workspace"),
	"you must be in the `examples/workspace` folder when running this script"
)

process.exec("rojo", { "build", "-o", "../package.rbxm" }, {
	cwd = "package",
})

process.exec("rojo", { "build", "-o", "../plugin.rbxm" }, {
	cwd = "plugin",
})

rbxasset.publishWorkspaceAsync(process.cwd, apiKey)
