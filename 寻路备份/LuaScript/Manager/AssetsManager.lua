---@class AssetsManager
AssetsManager = class()

function AssetsManager:ctor()
    self.assetCache = { }
end

---@param assetPaths string[] @路径集合
---@param finishCallback function @加载完成回调
---@param processCallback function @加载进度回调
function AssetsManager:LoadAssets(assetPaths, finishCallback, processCallback)
    local assetPathList

    for _,v in pairs(assetPaths) do
        if self.assetCache[v] or self:HasAsset(v) then
            -- do nothing
        else
            if not assetPathList then
                assetPathList = StringList()
            end
            if not assetPathList:Contains(v) then
                assetPathList:AddItem(v)
            end
        end
    end

    if not assetPathList then
        if finishCallback then
            finishCallback()
        end
        return
    end

    local function OnLoadFinish(sender)
        local loadedAssetList = sender
        for i = 0, loadedAssetList:GetItemCount() - 1 do
            local key = loadedAssetList:GetItem(i)
            self.assetCache[key] = true
        end
    end

    local function OnLoadProcess(sender)
        if processCallback ~= nil then
            processCallback(sender)
        end
    end
    AssetLoaderUtil.LoadAssets(assetPathList, OnLoadFinish, finishCallback, OnLoadProcess)
end

---@param assetPaths string[] @路径集合
---@param finishCallback function @加载完成回调
---@param processCallback function @加载进度回调
function AssetsManager:PrefetchAssets(assetPaths, finishCallback, processCallback)
    local assetPathList = StringList()
    for _,v in pairs(assetPaths) do
        assetPathList:AddItem(v)
    end

    local function OnLoadFinish(sender)
        local loadedAssetList = sender
        for i = 0, loadedAssetList:GetItemCount() - 1 do
            local key = loadedAssetList:GetItem(i)
            self.assetCache[key] = true
        end
    end

    local function OnLoadProcess(sender)
        if processCallback ~= nil then
            processCallback(sender)
        end
    end
    AssetLoaderUtil.LoadAssets(assetPathList, OnLoadFinish, finishCallback, OnLoadProcess)
end

function AssetsManager:HasAsset(path)
    return AssetLoaderUtil.HasAsset(path)
end

function AssetsManager:AssetExist(path)
    return AssetLoaderUtil.AssetExist(path)
end

function AssetsManager:GetAsset(path)
    return AssetLoaderUtil.GetAsset(path)
end

function AssetsManager:SetBundlesPersist(bundles)
    local caches = StringList()
    for _,v in pairs(bundles) do
        caches:AddItem(v)
    end
    AssetLoaderUtil.SetBundlesPersist(caches)
end

function AssetsManager:DestroyAsset(path)
    self.assetCache[path] = nil
    AssetLoaderUtil.DestroyAsset(path)
end

function AssetsManager:DestroyAllAssets()
    if RuntimeContext.ENABLE_ASSET_CACHE then return end
    for key, _ in pairs(self.assetCache) do
        self:DestroyAsset(key)
    end
    self.assetCache = {}
end
