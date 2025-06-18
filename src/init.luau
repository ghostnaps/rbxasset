local types = require("@self/types")

export type Manifest = types.Manifest
export type Lockfile = types.Lockfile

return {
	publishPackageAsync = require("@self/requests/publishPackageAsync"),
	publishWorkspaceAsync = require("@self/requests/publishWorkspaceAsync"),
}
