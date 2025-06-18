local fs = require("@lune/fs")
local serde = require("@lune/serde")

local constants = require("@root/constants")
local logging = require("@root/logging")
local types = require("@root/types")

type Lockfile = types.Lockfile

local function writeLockfile(packagePath: string, lockfile: Lockfile)
	local lockfilePath = `{packagePath}/{constants.ASSET_LOCKFILE_FILENAME}`
	fs.writeFile(lockfilePath, serde.encode("toml", lockfile))

	logging.debug(`wrote asset lockfile {lockfilePath}`)
end

return writeLockfile
