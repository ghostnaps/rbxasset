local frktest = require("@pkg/frktest/src/frktest")
local test = frktest.test
local check = frktest.assert.check

local getOrCreateAssetManifest = require("./getOrCreateAssetManifest")

test.case("reads an asset manifest from disk", function()
	local manifest = getOrCreateAssetManifest("examples/package")
	check.equal(manifest.assets["package"].assetId, "70942996502762")
end)

test.case("creates a blank asset manifest when not found on disk", function()
	local manifest = getOrCreateAssetManifest("/nowhere")
	check.table.equal(manifest, {
		assets = {},
		images = {},
	})
end)
