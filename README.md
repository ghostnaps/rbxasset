# rbxasset

# Installation

Requires [Lune](https://github.com/lune-org/lune) 0.9.3+

```sh
$ git clone https://github.com/ghostnaps/rbxasset.git
```

# Usage

Create an `rbxasset.toml` file in your project with the following content:

```toml
[asset]
name = "Display Name"
description = "Longform project description"
icon = "img/icon.png"
distribute = false

[creator]
creatorId = 1234567
creatorType = "User"
```

## Package syncing

The following example will take an rbxm file and upload it to the Creator Store using `rbxasset.toml` to define what the
display name, description, and icon will be.

```luau
-- .lune/publish.luau
local process = require("@lune/process")

local rbxasset = require("rbxasset")

local content = process.args[1]
local apiKey = process.args[2]

local assetConfig = rbxasset.readAssetConfig(process.cwd)

rbxasset.syncPackage(assetConfig, content, apiKey)
```

```sh
$ lune run publish build.rbxm <API_KEY>
```

Where `<API_KEY>` represents an Open Cloud API key with `asset:read` and `asset:write` permissions.

# API

## Types

### AssetConfig

```luau
export type AssetConfig = {
	name: string,
	description: string?,
	icon: string?,
	thumbnails: { string }?,
	private: boolean?,
}
```

### AssetManifest

```luau
type Image = {
	assetId: string,
	hash: string,
}

export type AssetManifest = {
	assetId: string,
	images: { [string]: Image }?,
}
```

## Functions

### createDecalAsync

### getAssetDetailsAsync

### readAssetConfig

`readAssetConfig(projectPath: string): AssetConfig`

### maybeReadAssetManifest

`maybeReadAssetManifest(projectPath: string): AssetManifest?`

### writeAssetManifest

`writeAssetManifest(projectPath: string, manifest: AssetManifest)`

### setAssetDetailsAsync

### waitForOperationAsync

