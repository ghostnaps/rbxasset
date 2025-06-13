local process = require("@lune/process")

local logging = require("@root/logging")

type Options = {
	cwd: string?,
	env: { [string]: any }?,
}

local function run(program: string, params: { string }, options: Options?): string
	logging.debug(`RUN > {program} {table.concat(params, " ")}`)

	local result = process.exec(program, params, {
		stdio = "inherit",
		shell = true,
		cwd = if options then options.cwd else nil,
		env = if options then options.env else nil,
	})

	if result.code == 0 then
		return result.stdout:gsub("\n$", "")
	else
		error(result.stderr)
	end
end

return run
