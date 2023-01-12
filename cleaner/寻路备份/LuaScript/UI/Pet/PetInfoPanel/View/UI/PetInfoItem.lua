---@type PetTemplateTool
local PetTemplateTool = require "Cleaner.Entity.Pet.PetTemplateTool"
---@type PetInfoTypeEnum
local PetInfoTypeEnum = require "UI.Pet.PetInfoPanel.View.UI.PetInfoTypeEnum"

---@class PetInfoItem
local PetInfoItem = class(nil, "PetInfoItem")

local PetUpType = {
    None = 0,
    Level = 1,
    Stage = 2,
}

function PetInfoItem:ctor(itemGo, pet, type, panel)
    self.itemGo = itemGo
    self.pet = pet
    self.type = type
    self.panel = panel
    self.petKey = 0
end

function PetInfoItem:refresh()
    self.icon = find_component(self.itemGo,'Icon',Image)
    self.txt_name = find_component(self.itemGo,'txt_name',Text)
    self.stage = find_component(self.itemGo, 'Stage', Transform)
    self.stageItem = find_component(self.itemGo, 'Stage/Item', Transform)

    self.team = find_component(self.itemGo, 'Team', Transform)
    self.other = find_component(self.itemGo, 'Other', Transform)

    self:refreshInfo()
    self:refreshStage()
    self:refreshType()

    self:RegisterEvent()
end

function PetInfoItem:refreshInfo()
    self.petKey = PetTemplateTool:Getkey(self.pet.type, self.pet.level)
    self.petConfigData = AppServices.Meta:Category("PetTemplate")[tostring(self.petKey)]

    self.icon.sprite = self:GetItemSprite(self.petConfigData.icon)
    self.txt_name.text = string.format("%s Lv.%d",  self.petConfigData.name,  self.petConfigData.level)
    self.txt_up_info = find_component(self.itemGo,'txt_up_info',Text)
end

function PetInfoItem:refreshStage()
    local maxStage = PetTemplateTool:GetMaxStage(self.pet.type)

    for stage = 1, maxStage do
        local go = self.panel:CreateItem(self.stageItem, self.stage)
        local txt_name = find_component(go, "txt_name", Text)
        txt_name.text = tostring(stage)

        local name = "Middle"
        if stage == 1 then
            name = "Start"
        elseif stage == maxStage then
            name = "End"
            local split = find_component(go, 'Split', Transform)
            split.gameObject:SetActive(false)
        end
        local item = go.transform:Find(name).gameObject:GetComponent(typeof(Transform))

        local show = self.petConfigData.stage >= stage
        item.gameObject:SetActive(show)
    end
end

function PetInfoItem:refreshType()
    local showTeam = self.type == PetInfoTypeEnum.Team
    self.team.gameObject:SetActive(showTeam)
    self.other.gameObject:SetActive(not showTeam)

    if self.type == PetInfoTypeEnum.Team then
        self:TypeBtn(self.team.gameObject)

    elseif self.type == PetInfoTypeEnum.Other then
        self:TypeBtn(self.other.gameObject)
    end
end

function PetInfoItem:TypeBtn(typeGo)
    self:UpInfo()

    local btn_upgrade = find_component(typeGo, 'btn_upgrade', Button)
    local icon = find_component(typeGo, 'btn_upgrade/icon', Image)
    local txt_cost_upgrade = find_component(typeGo, 'btn_upgrade/txt_cost', Text)
    local upgrade_disable =find_component(typeGo, 'btn_upgrade/disable', Transform)

    local btn_stage = find_component(typeGo, 'btn_stage', Button)
    local txt_name = find_component(typeGo, 'btn_stage/txt_name', Text)

    self.itemNotEnougths = {}
    if self.petConfigData.upgradeCost and #self.petConfigData.upgradeCost > 0 then
        local itemKey = tostring(self.petConfigData.upgradeCost[1][1])
        local itemData = AppServices.Meta:Category("ItemTemplate")[itemKey]
        icon.sprite = self:GetItemSprite(itemData.icon)
        local cost = self.petConfigData.upgradeCost[1][2]
        txt_cost_upgrade.text = tostring(cost)

        local ownerCount = AppServices.User:GetItemAmount(tonumber(itemKey))
        if ownerCount < cost then
            table.insert(self.itemNotEnougths, itemKey)
        end
    end

    local upType = self:UpType()
    btn_upgrade.gameObject:SetActive(upType == PetUpType.Level)
    local enableUp = self:EnableUp()
    upgrade_disable.gameObject:SetActive(enableUp ~= UpgradeEnableType.Enable)
    btn_stage.gameObject:SetActive(upType == PetUpType.Level)

    Util.UGUI_AddButtonListener(btn_upgrade.gameObject, function()
        self:UpgradeClick()
    end)

    --local stage_disable =find_component(typeGo, 'btn_stage/disable', Transform)
    txt_name.text = "进阶"
    btn_stage.gameObject:SetActive(upType == PetUpType.Stage)

    Util.UGUI_AddButtonListener(btn_stage.gameObject, function()
        self:StageClick()
    end)

    local btn_team = find_component(typeGo, 'btn_team', Button)
    local txt_team = find_component(typeGo, 'btn_team/txt_team', Text)
    if Runtime.CSValid(btn_team) then
        txt_team.text = "上阵"

        Util.UGUI_AddButtonListener(btn_team.gameObject, function()
            self:TeamClick()
        end)
    end
end

function PetInfoItem:EnableUp()
    local itemEnougth = AppServices.ItemCostManager:IsItemEnougth(self.petConfigData.upgradeCost)
    local playerLevel = AppServices.User:GetPlayerLevel()
    local petLevel = self.petConfigData.level

    if not itemEnougth then
        return UpgradeEnableType.ItemNotEnougth
    end

    if petLevel >= playerLevel then
        return UpgradeEnableType.PlayerLevelSmall
    end
    return UpgradeEnableType.Enable
end

function PetInfoItem:UpInfo()
    local upType, nextLevelData = self:UpType()

    self.txt_up_info.gameObject:SetActive(upType ~= PetUpType.None)
    if upType == PetUpType.None then
        return
    end

    local hp = nextLevelData.hp - self.petConfigData.hp
    local skillData = AppServices.Meta:Category("SkillTemplate")[tostring(self.petConfigData.skillId)]
    local nextSkillData = AppServices.Meta:Category("SkillTemplate")[tostring(nextLevelData.skillId)]
    local attack = nextSkillData.attackPower - skillData.attackPower

    if upType == PetUpType.Level then
        self.txt_up_info.text = string.format("升级提升%d血量, %d攻击", hp, attack)
    else
        local nextStageMaxLevel = PetTemplateTool:GetStageMaxLelel(self.petConfigData.type, self.petConfigData.stage + 1)
        self.txt_up_info.text = string.format("提升等级上限至%d", nextStageMaxLevel)
    end
end

function PetInfoItem:UpType()
    local nextLevelKey = PetTemplateTool:Getkey(self.pet.type, self.pet.level + 1)
    if nextLevelKey <= 0 then
        return PetUpType.None
    end

    local nextLevelData =  AppServices.Meta:Category("PetTemplate")[tostring(nextLevelKey)]
    if self.petConfigData.stage == nextLevelData.stage then
        return PetUpType.Level, nextLevelData
    end
    return PetUpType.Stage, nextLevelData
end

-- 升级点击
function PetInfoItem:UpgradeClick()
    local enableUp = self:EnableUp()
    if enableUp == UpgradeEnableType.ItemNotEnougth and self.itemNotEnougths then
        local msg = "资源不足:"
        for _, key in pairs(self.itemNotEnougths) do
           msg = msg.." "..key
        end
        AppServices.UITextTip:Show(msg)
    elseif enableUp == UpgradeEnableType.PlayerLevelSmall then
        AppServices.UITextTip:Show("宠物等级不能高于玩家等级")
    end
    if enableUp ~= UpgradeEnableType.Enable then
        return
    end

    AppServices.NetPetManager:SendPetLevelUp(self.pet.id, self.pet.level + 1)
end

-- 升星点击
function PetInfoItem:StageClick()
    --local enableUp = self:EnableUp()
    -- if enableUp ~= UpgradeEnableType.Enable then
    --     return
    -- end

    --PanelManager.closePanel(GlobalPanelEnum.PetInfoPanel, nil)

    local arguments = {type = self.pet.type, level = self.pet.level}
    PanelManager.showPanel(GlobalPanelEnum.PetUpStagePanel, arguments)
end

-- 上阵点击
function PetInfoItem:TeamClick()
    PanelManager.closePanel(GlobalPanelEnum.PetInfoPanel, nil)

    local arguments = {editorPetId = self.pet.id}
    PanelManager.showPanel(GlobalPanelEnum.PetIllustratedPanel, arguments)
end

function PetInfoItem:GetItemSprite(spriteName)
    local atlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_ITEM_ICONS)
    local sprite = atlas:GetSprite(spriteName)
    return sprite
end

function PetInfoItem:ReceiveUpgrade(type, level)
    if self.pet.type ~= type then
        return
    end
    self.pet = AppServices.User:GetPet(self.pet.id)

    self:refreshInfo()
    self:refreshType()
end

function PetInfoItem:RegisterEvent()
    MessageDispatcher:AddMessageListener(MessageType.PetUpLevel, self.ReceiveUpgrade, self)
end

function PetInfoItem:UnRegisterEvent()
    MessageDispatcher:RemoveMessageListener(MessageType.PetUpLevel, self.ReceiveUpgrade, self)
end

function PetInfoItem:Destroy()
    GameObject.Destroy(self.itemGo)
    self:UnRegisterEvent()
end

return PetInfoItem