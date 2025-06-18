local types = require("@self/types")

export type Config = types.Config
export type Lockfile = types.Lockfile

return {
	publishPackageAsync = require("@self/requests/publishPackageAsync"),
	publishWorkspaceAsync = require("@self/requests/publishWorkspaceAsync"),
}
