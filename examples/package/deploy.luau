local rbxasset = require("@root/")

local process = require("@lune/process")

local apiKey = process.args[1]

assert(process.cwd:match("examples/package"), "you must be in the `examples/package` folder when running this script")

process.exec("rojo", { "build", "-o", ".package.rbxm" })

rbxasset.publishPackageAsync(process.cwd, apiKey)
