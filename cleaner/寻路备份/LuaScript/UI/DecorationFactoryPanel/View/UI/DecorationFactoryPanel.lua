--insertWidgetsBegin
--    btn_close    go_levelup    go_product
--insertWidgetsEnd

--insertRequire
local _DecorationFactoryPanelBase = require "UI.DecorationFactoryPanel.View.UI.Base._DecorationFactoryPanelBase"

---@class DecorationFactoryPanel:_DecorationFactoryPanelBase
local DecorationFactoryPanel = class(_DecorationFactoryPanelBase)

function DecorationFactoryPanel:ctor()

end

function DecorationFactoryPanel:onAfterBindView()
    self.agentId = self.arguments.agentId
    self:refreshAgentInfo()
    self:refreshUI()
end

function DecorationFactoryPanel:refreshAgentInfo()
    local agent = App.scene.objectManager:GetAgent(self.agentId)
    if not agent then
        return
    end
    self.level = agent:GetLevel()
    self.sn = agent:GetTemplateId()
    local cfg = agent:GetMeta()
    Runtime.Localize(self.txt_name, cfg.name)
end

function DecorationFactoryPanel:refreshUI(isSwitchTab)
    local idx = self._lastIndex
    if isSwitchTab then
        self.go_product:SetActive(idx == 1)
        self.go_levelup:SetActive(idx == 2)
        self.go_levelmax:SetActive(false)
    end
    if idx == 1 then
        self:refreshProduct()
    elseif idx == 2 then
        self:refreshLvup()
    end
end


function DecorationFactoryPanel:OnClickTap(idx)
    if self._lastIndex == idx then
        return
    end
    self._lastIndex = idx
    self:refreshUI(true)
end

function DecorationFactoryPanel:refreshProduct()
    self.txt_curLevel.text = string.format("Lv.%d", self.level)
    local production = SceneServices.DecorationFactory:GetProduction()
    local costs = production.recipe
    local gos = self:CopyComponent(self.go_productCostNode, self.go_productCost, #costs)
    for i, go in ipairs(gos) do
        local item = costs[i]
        local itemId = item.key
        local count = AppServices.User:GetItemAmount(itemId)
        UITool.SetItemSlot(go, item.key, {total = item.value, count = count})
    end
end

function DecorationFactoryPanel:refreshLvup()
    local maxLv = SceneServices.DecorationFactory:GetMaxLevel()
    if self.level >= maxLv then
        self.go_levelmax:SetActive(true)
        self.go_levelup:SetActive(false)
        return
    end
    self.txt_level.text = string.format("Lv.%d", self.level)
    self.txt_level_next.text = string.format("Lv.%d", self.level + 1)
    local unlocks = SceneServices.DecorationFactory:GetLvupUnlocks(self.level + 1)
    local unlockGos = self:CopyComponent(self.go_unlockNode, self.go_unlocks, #unlocks)
    for i, unlockGo in ipairs(unlockGos) do
        local itemId = unlocks[i]
        local icon = find_component(unlockGo, "icon", Image)
        AppServices.ItemIcons:SetItemIcon(icon, itemId)
    end

    local buildingLvCfg = AppServices.BuildingLevelTemplateTool:GetConfig(self.sn, self.level)
    local lvupItems = buildingLvCfg.upgradeCost
    local lvupGos = self:CopyComponent(self.go_lvupNeedNode, self.go_lvupNeeds, #lvupItems)
    for i, lvupGo in ipairs(lvupGos) do
        local item = lvupItems[i]
        local itemId = item[1]
        local total = item[2]
        local have = AppServices.User:GetItemAmount(itemId)
        UITool.SetItemSlot(lvupGo, itemId, {count = have, total = total})
    end
end

return DecorationFactoryPanel
