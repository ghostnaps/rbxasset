local process = require("@lune/process")
local stdio = require("@lune/stdio")

type Options = {
	cwd: string?,
	env: { [string]: any }?,
}

local function run(program: string, params: { string }, options: Options?)
	stdio.write(stdio.style("bold"))
	print(`> {program} {table.concat(params, " ")}`)
	stdio.write(stdio.style("reset"))

	local child = process.create(program, params, {
		stdio = "inherit",
		shell = true,
		cwd = if options then options.cwd else nil,
		env = if options then options.env else nil,
	})

	local result = child:status()

	local output = if result.ok then child.stdout:readToEnd() else child.stderr:readToEnd()
	if result.code > 0 then
		error(output)
	end

	output = output:gsub("\n$", "")

	return output
end

return run
