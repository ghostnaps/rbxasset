local types = require("@self/types")

export type Config = types.Config
export type Manifest = types.Manifest

return {
	publishPackageAsync = require("@self/requests/publishPackageAsync"),
}
