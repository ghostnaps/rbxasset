local run = require("@root/lib/run")

local packages = "pkg"

local repos = {
	{
		url = "https://github.com/itsfrank/frktest",
		rev = "317703277919695241c7e32d15122f447a28be7b",
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
