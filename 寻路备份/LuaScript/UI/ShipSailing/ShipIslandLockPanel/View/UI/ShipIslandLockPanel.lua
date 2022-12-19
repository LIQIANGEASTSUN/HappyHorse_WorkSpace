---@type IslandTemplateTool
local IslandTemplateTool = require "Fsm.Ship.IslandTemplateTool"

--insertRequire
local _ShipIslandLockPanelBase = require "UI.ShipSailing.ShipIslandLockPanel.View.UI.Base._ShipIslandLockPanelBase"

---@class ShipIslandLockPanel:_ShipIslandLockPanelBase
local ShipIslandLockPanel = class(_ShipIslandLockPanelBase)

function ShipIslandLockPanel:ctor()

end

function ShipIslandLockPanel:SetArguments(arguments)
    self.islandId = arguments.islandId
end

function ShipIslandLockPanel:refreshUI()
    local islandConfig = IslandTemplateTool:GetData(self.islandId)
    local unlockCondition = islandConfig.unlockCondition

    if not unlockCondition or #unlockCondition <= 0 then
        return
    end

    for _, data in pairs(unlockCondition) do
        local result, msg, iconName = false, "empty", ""
        if data[1] == IslandUnlockCondition.ShipDock_Level then
            result, msg, iconName = self:ShipyardLevel(data)
        elseif data[1] == IslandUnlockCondition.Pre_island then
            result, msg, iconName = self:PreIsland(data)
        end

        --if not result then
            local go = self:CreateItem(self.itemCloneTr, self.itemParent)
            local txt_info  = find_component(go,'txt_info',Text)
            local icon = find_component(go,'BG/Icon',Image)
            txt_info.text = msg
        if iconName ~= "" then
            icon.sprite = self:GetSprite(iconName)
        end
        --end
    end
end

function ShipIslandLockPanel:ShipyardLevel(data)
    local result = AppServices.IslandManager:CheckShipyardLevel(data)
    local msg = string.format("升级船坞至%d级", data[2])
    return result, msg, ""
end

function ShipIslandLockPanel:PreIsland(data)
    local result = AppServices.IslandManager:CheckIslandProgress(data)

    local preIslandId = data[2]
    local preIslandConfig = IslandTemplateTool:GetData(preIslandId)
    local msg = string.format("%s探索度100%s", preIslandConfig.name, "%")
    return result, msg, preIslandConfig.icon
end

function ShipIslandLockPanel:CreateItem(cloneTr, parent)
    local go = GameObject.Instantiate(cloneTr.gameObject)
    go.transform:SetParent(parent, false)
    go.transform.localScale = Vector3.one
    go.transform.localEulerAngles = Vector3.zero
    go.transform.localPosition = Vector3.zero
    go:SetActive(true)
    return go
end

function ShipIslandLockPanel:GetSprite(spriteName)
    local atlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_ISLAND_SPRITE)
    local sprite = atlas:GetSprite(spriteName)
    return sprite
end

function ShipIslandLockPanel:Hide()

end

return ShipIslandLockPanel
