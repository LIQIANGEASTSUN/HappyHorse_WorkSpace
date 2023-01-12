---@class BundleManager
local BundleManager = {
    cache = {}
}

---@param bundles string[] @路径集合
---@param finishCallback function @加载完成回调
---@param processCallback function @加载进度回调
---@param loadingFlag any
function BundleManager:LoadBundles(bundles, finishCallback, processCallback)
    local assetPathList = nil

    for _,v in pairs(bundles) do
        if self.cache[v] then
            -- do nothing
        else
            if not assetPathList then
                assetPathList = StringList()
            end
            assetPathList:AddItem(v)
            --print("loading assset " .. v) --@DEL
        end
    end

    if not assetPathList then
        return finishCallback()
    end

    local function OnLoadFinish(sender)
        return finishCallback()
    end

    local function OnLoadProcess(sender)
        if processCallback ~= nil then
            processCallback(sender)
        end
    end
    AssetLoaderUtil.LoadBundles(assetPathList, OnLoadFinish, OnLoadProcess)
end

function BundleManager:SetBundlesPersist(bundles)
    local caches = StringList()
    for _,v in pairs(bundles) do
        caches:AddItem(v)
    end
    AssetLoaderUtil.SetBundlesPersist(caches)
end

return BundleManager