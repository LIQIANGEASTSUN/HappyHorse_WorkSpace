---@class ClickEffectTool
local ClickEffectTool = {
    cacheClickGroundEffects = {},
    cacheClickEffects = {},
    init = false
}

function ClickEffectTool.Destroy()
    self:OnDestroy()
end

function ClickEffectTool:Init()
    if true then
        return
    end
    if Runtime.CSNull(self.gameObject) then
        self.initializing = nil
    end
    if self.initializing then
        return
    end
    self.initializing = true

    local onLoaded = function(sender)
        self.init = true
        self.clickGroundPrefab = BResource.InstantiateFromAssetName(CONST.ASSETS.G_E_Clickground)
        self.clickGroundPrefab:SetActive(false)
        self.clickPrefab = BResource.InstantiateFromAssetName(CONST.ASSETS.G_E_Click)
        self.clickPrefab:SetActive(false)

        if self.cacheDatas then
            for _, cache in pairs(self.cacheDatas) do
                self:Show(cache.passable, cache.position)
            end
            self.cacheDatas = nil
        end
    end

    App.uiAssetsManager:LoadAssets(
        {
            CONST.ASSETS.G_E_Clickground,
            CONST.ASSETS.G_E_Click
        },
        onLoaded
    )
end

---@param passable boolean
---@param position Vector3
function ClickEffectTool:Show(passable, position)
    if true then
        return
    end
    if not position then
        return
    end

    local prefab = passable and self.clickGroundPrefab or self.clickPrefab

    if Runtime.CSNull(prefab) then
        self.init = false
    end

    if not self.init then
        self.cacheDatas = self.cacheDatas or {}
        table.insert(
            self.cacheDatas,
            {
                passable = passable,
                position = position
            }
        )

        self:Init()
        return
    end
    local tip = self:Get(passable)
    if not tip then
        return
    end

    tip:SetPosition(position)
    tip:Show()
end

function ClickEffectTool:Get(passable)
    local group = passable and self.cacheClickGroundEffects or self.cacheClickEffects

    for _, tip in pairs(group) do
        if Runtime.CSNull(tip.gameObject) then
            table.remove(group, _)
        else
            if not tip.inUse then
                return tip
            end
        end
    end

    local prefab = passable and self.clickGroundPrefab or self.clickPrefab

    local go = GameObject.Instantiate(prefab)
    go:SetParent(self:GetParent(), false)
    local tip = {
        gameObject = go,
        inUse = false
    }
    tip.SetPosition = function(tip, position)
        tip.gameObject:SetPosition(position)
    end
    tip.Show = function(tip)
        tip.inUse = true
        tip.gameObject:SetActive(true)
        WaitExtension.SetTimeout(
            function()
                tip.inUse = false
                if Runtime.CSValid(tip.gameObject) then
                    tip.gameObject:SetActive(false)
                end
            end,
            2
        )
    end

    table.insert(group, tip)
    return tip
end

function ClickEffectTool:GetParent()
    if Runtime.CSValid(self.root) then
        return self.root
    end
    self.root = GameObject("ClickEffect")
    return self.root
end

function ClickEffectTool:OnDestroy()
    Runtime.CSDestroy(self.gameObject)
    self.gameObject = nil
end

return ClickEffectTool
