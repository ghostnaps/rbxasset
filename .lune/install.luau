local run = require("@root/lib/run")

local packages = "pkg"

local repos = {
	"itsfrank/frktest@31770327",
	"osyrisrblx/t@1dbfccc1",
}

run("rm", { "-rf", packages })

for _, repo in repos do
	local parts = repo:split("@")
	local repoPath = parts[1]
	local rev = parts[2]

	local projectName = repoPath:split("/")[2]
	local dest = `{packages}/{projectName}`

	run("git", { "clone", `https://github.com/{repoPath}`, dest })

	run("git", { "reset", "--hard", rev }, {
		cwd = dest,
	})
end
