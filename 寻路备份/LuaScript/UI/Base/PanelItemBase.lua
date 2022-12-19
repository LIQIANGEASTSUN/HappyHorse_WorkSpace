require "UI.Base.Utils"
---@class PanelItemBase
PanelItemBase = class(nil)

function PanelItemBase.Create(parentPanel, assetPath, ...)
    local instance = PanelItemBase.new(parentPanel, ...)
    local go = BResource.InstantiateFromAssetName(assetPath)
    instance:InitWithGameObject(go, ...)
    return instance
end

function PanelItemBase:ctor(parentPanel, ...)
    self.parentPanel = parentPanel
    self.isDisposed = false
end

function PanelItemBase:IsDisposed()
    return self.isDisposed
end

function PanelItemBase:InitWithGameObject(go)
    console.assert(false, "must over write in child")
end

function PanelItemBase:GetRectTransform()
    if self.rectTransform == nil then
        self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
    end
    return self.rectTransform
end

function PanelItemBase:CopyComponent(go, parentGo, num)
    if not self.copyComponents then
        self.copyComponents = {}
    end
    if not self.copyComponents[go] then
        self.copyComponents[go] = {go}
    end
    local have = #self.copyComponents[go]
    if num == 0 and have > 0 then
        for i, v in ipairs(self.copyComponents[go]) do
            v:SetActive(false)
        end
        return
    end
    if have < num then
        for i = have + 1, num do
            local copyGo = BResource.InstantiateFromGO(go)
            copyGo.transform:SetParent(parentGo.transform, false)
            copyGo:SetActive(false)
            table.insert(self.copyComponents[go], copyGo)
        end
        have = #self.copyComponents[go]
    end
    local ret = {}
    for i = 1, have do
        local retGo = self.copyComponents[go][i]
        if i <= num then
            retGo:SetActive(true)
            table.insert(ret, retGo)
        else
            retGo:SetActive(false)
        end
    end
    return ret
end

function PanelItemBase:SetComponentVisible(com, visible)
    if com == nil then
        return
    end
    if com.gameObject == nil then
        return
    end
    if visible then
        com.gameObject:SetActive(true)
    else
        com.gameObject:SetActive(false)
    end
end

function PanelItemBase:setActive(active)
    if Runtime.CSNull(self.gameObject) then
        return
    end

    if (active) then
        self.gameObject:SetActive(true)
    else
        self.gameObject:SetActive(false)
    end
end

function PanelItemBase:DisposeLua()
    self.isDisposed = true
    self.copyComponents = nil
    Runtime.CSDestroy(self.gameObject)
    self.gameObject = nil
end
function PanelItemBase:destroy()
    self:DisposeLua()
end
