local frktest = require("@pkg/frktest/src/frktest")
local test = frktest.test
local check = frktest.assert.check

local types = require("./types")

test.suite("validateConfig", function()
	test.case("accepts minimal config", function()
		local success = types.validateConfig({
			assets = {
				main = {
					name = "Asset Name",
					environment = "production",
				},
			},
			environments = {
				production = {
					creatorId = 1234567,
					creatorType = "User",
					universeId = 10101010,
					placeId = 20202020,
				},
			},
		})

		check.is_true(success)
	end)

	test.case("accepts optional config values", function()
		local success = types.validateConfig({
			assets = {
				main = {
					name = "Asset Name",
					environment = "production",
					description = "Asset description",
					icon = "icon.png",
					thumbnails = { "thumbnails/1.png" },
					distribute = true,
				},
			},
			environments = {
				production = {
					creatorId = 1234567,
					creatorType = "User",
					universeId = 10101010,
					placeId = 20202020,
				},
			},
		})

		check.is_true(success)
	end)

	test.case("denies empty assets object", function()
		local success, message = types.validateConfig({
			assets = {},
			environments = {
				production = {
					creatorId = 1234567,
					creatorType = "User",
					universeId = 10101010,
					placeId = 20202020,
				},
			},
		})

		check.is_false(success)
		check.equal(message, "at least one asset must be defined in the config")
	end)

	test.case("denies empty environments object", function()
		local success, message = types.validateConfig({
			assets = {
				main = {
					name = "Asset Name",
					description = "Asset description",
					icon = "icon.png",
					thumbnails = { "thumbnails/1.png" },
					distribute = true,
					environment = "does-not-exist",
				},
			},
			environments = {},
		})

		check.is_false(success)
		check.equal(message, "at least one environment must be defined in the config")
	end)

	test.case("assets must map back to a valid environment", function()
		local success, message = types.validateConfig({
			assets = {
				main = {
					name = "Asset Name",
					description = "Asset description",
					icon = "icon.png",
					thumbnails = { "thumbnails/1.png" },
					distribute = true,
					environment = "does-not-exist",
				},
			},
			environments = {
				production = {
					creatorId = 1234567,
					creatorType = "User",
					universeId = 10101010,
					placeId = 20202020,
				},
			},
		})

		check.is_false(success)
		check.equal(message, `asset "main" attempts to use the environment "does-not-exist" which does not exist`)
	end)

	test.case("denies optional config values of the wrong type", function()
		local success = types.validateConfig({
			assets = {
				main = {
					name = "Asset Name",
					environment = "production",
					description = 123456789,
					icon = false,
				},
			},
			environments = {
				production = {
					creatorId = 1234567,
					creatorType = "User",
					universeId = 10101010,
					placeId = 20202020,
				},
			},
		})

		check.is_false(success)
	end)

	test.case("denies empty object", function()
		local success = types.validateConfig({})

		check.is_false(success)
	end)

	test.case("denies invalid types", function()
		local success = types.validateConfig({
			assets = {
				main = {
					name = false,
					environment = "production",
				},
			},
			environments = {
				production = {
					creatorId = 1234567,
					creatorType = "User",
					universeId = 10101010,
					placeId = 20202020,
				},
			},
		})

		check.is_false(success)
	end)
end)

test.suite("validateManifest", function()
	test.case("must have an assetId", function()
		local success = types.validateManifest({
			assets = {
				foo = {
					assetId = "123456789",
				},
			},
			images = {},
		})

		check.is_true(success)
	end)

	test.case("handles storing images", function()
		local success = types.validateManifest({
			assets = {
				foo = {
					assetId = "123456789",
				},
			},
			images = {
				["icon.png"] = {
					assetId = "987654321",
					hash = "image-hash",
				},
			},
		})

		check.is_true(success)
	end)

	test.case("denies empty object", function()
		local success = types.validateManifest({})

		check.is_false(success)
	end)
end)
