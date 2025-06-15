local console_reporter = require("@pkg/frktest/src/reporters/console_reporter")
local frktest = require("@pkg/frktest/src/frktest")
local run = require("@root/lib/run")

local function loadTestCases()
	local output = run("find", { "src", "-iname", "*.spec.luau" })
	output = output:gsub("src/", "@root/")

	local files = output:split("\n")

	print("files", files)

	for _, file in files do
		(require :: any)(file)
	end
end

loadTestCases()

console_reporter.init()
frktest.run()
