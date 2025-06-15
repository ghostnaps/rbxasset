local frktest = require("@pkg/frktest/src/frktest")
local test = frktest.test
local check = frktest.assert.check

local types = require("./types")

test.suite("validateAssetConfig", function()
	test.case("accepts minimal config", function()
		local success = types.validateAssetConfig({
			asset = {
				name = "Asset Name",
			},
			deployment = {
				creatorId = 1234567,
				creatorType = "User",
				universeId = 10101010,
				placeId = 20202020,
			},
		})

		check.is_true(success)
	end)

	test.case("accepts optional config values", function()
		local success = types.validateAssetConfig({
			asset = {
				name = "Asset Name",
				description = "Asset description",
				icon = "icon.png",
				thumbnails = { "thumbnails/1.png" },
				distribute = true,
			},
			deployment = {
				creatorId = 1234567,
				creatorType = "User",
				universeId = 10101010,
				placeId = 20202020,
			},
		})

		check.is_true(success)
	end)

	test.case("denies optional config values of the wrong type", function()
		local success = types.validateAssetConfig({
			asset = {
				name = "Asset Name",
				description = 123456789,
				icon = false,
			},
			deployment = {
				creatorId = 1234567,
				creatorType = "User",
				universeId = 10101010,
				placeId = 20202020,
			},
		})

		check.is_false(success)
	end)

	test.case("denies empty object", function()
		local success = types.validateAssetConfig({})

		check.is_false(success)
	end)

	test.case("denies invalid types", function()
		local success = types.validateAssetConfig({
			asset = {
				name = false,
			},
			deployment = {
				creatorId = 1234567,
				creatorType = "User",
				universeId = 10101010,
				placeId = 20202020,
			},
		})

		check.is_false(success)
	end)
end)

test.suite("validateAssetManifest", function()
	test.case("must have an assetId", function()
		local success = types.validateAssetManifest({
			assetId = "123456789",
		})

		check.is_true(success)
	end)

	test.case("handles storing images", function()
		local success = types.validateAssetManifest({
			assetId = "123456789",
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
		local success = types.validateAssetManifest({})

		check.is_false(success)
	end)
end)
