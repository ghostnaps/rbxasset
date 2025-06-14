
# publishPackageAsync

```mermaid
flowchart TD;
    Start([Start])
        --> Configure(Configure rbxasset.toml to set name, description, icon, distribution status, etc.)
         --> Build(Build rbxm)
         --> BeginPublishing

    subgraph rbxasset
        AssetConfig[(rbxasset.toml)]
        AssetManifest[(rbxasset-manifest.toml)]

        BeginPublishing("publishPackageAsync()")
            --> AssetExists{Asset exists on Creator Store?}

        AssetExists -- Yes  --> UpdateVersion(Update asset version with new rbxm)
        AssetExists -- No --> CreateAsset(Create new Package asset)

        AssetManifest -. read assetId .-> UpdateVersion

        CompareImageHashes{For each image, is there a matching hash?}
        CompareImageHashes -- Yes --> SyncAssetDetails
        CompareImageHashes -- No --> UploadImages

        AssetManifest -. read image hashes .-> CompareImageHashes

        CreateAsset -. write assetId .-> AssetManifest

        UploadImages(Create Image assets for the icon and previews)

        AssetConfig -. read image paths .-> UploadImages

        SyncAssetDetails(Sync asset name, description, icon, and distribution status to Creator Store)
        AssetConfig -. read name, description, distribution status .-> SyncAssetDetails

        UpdateVersion
            --> CreateAssetVersionAsync("AssetService:CreateAssetVersionAsync()")
            --> CompareImageHashes

        CreateAsset
            --> CreateAssetAsync("AssetService:CreateAssetAsync()")
            --> CompareImageHashes

        UploadImages --> SyncAssetDetails
        UploadImages -. store image hash and id .->  AssetManifest
    end

    SyncAssetDetails
        --> CreatorStore([Asset successfully published to Creator Store])
```
