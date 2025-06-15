local run = require("@root/lib/run")

local packages = "pkg"

local repos = {
	{
		url = "https://github.com/itsfrank/frktest",
		rev = "317703277919695241c7e32d15122f447a28be7b",
	},
	{
		url = "https://github.com/osyrisrblx/t",
		rev = "1dbfccc182d5870cca5266dd6f3d81618f69fc29",
	},
}

run("rm", { "-rf", packages })

for _, repo in repos do
	local projectName = repo.url:match(".+/(.+)$")
	local dest = `{packages}/{projectName}`

	run("git", { "clone", repo.url, dest })

	run("git", { "reset", "--hard", repo.rev }, {
		cwd = dest,
	})
end
