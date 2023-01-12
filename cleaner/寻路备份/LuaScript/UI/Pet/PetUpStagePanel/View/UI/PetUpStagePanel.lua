---@type PetTemplateTool
local PetTemplateTool = require "Cleaner.Entity.Pet.PetTemplateTool"

--insertWidgetsBegin
--insertWidgetsEnd

--insertRequire
local _PetUpStagePanelBase = require "UI.Pet.PetUpStagePanel.View.UI.Base._PetUpStagePanelBase"

---@class PetUpStagePanel:_PetUpStagePanelBase
local PetUpStagePanel = class(_PetUpStagePanelBase)

local UpType = {
    Enable = 1,
    Item_Not_Enougth = 2,
    Level_Not_Small_Than_Player = 3,
}

function PetUpStagePanel:ctor()

end

function PetUpStagePanel:onAfterBindView()

end

function PetUpStagePanel:SetArguments(arguments)
    self.arguments = arguments
end

function PetUpStagePanel:refreshUI()
    self.petKey = PetTemplateTool:Getkey(self.arguments.type, self.arguments.level)
    self.petConfigData = AppServices.Meta:Category("PetTemplate")[tostring(self.petKey)]

    self.pet = AppServices.User:GetPetWithType(self.arguments.type)
    --[[
		self.itemParent = transform:Find("BG/Layout")
    --]]
    -- self.txt_title
    -- self.txt_level_info

    self.icon.sprite = self:GetItemSprite(self.petConfigData.icon)

    local stageMaxLevel = PetTemplateTool:GetStageMaxLelel(self.petConfigData.type, self.petConfigData.stage)
    local nextStageMaxLevel = PetTemplateTool:GetStageMaxLelel(self.petConfigData.type, self.petConfigData.stage + 1)
    self.txt_level_info.text = string.format("进阶后等级上限由%d提升至%d", stageMaxLevel, nextStageMaxLevel)

    -- self.txt_cost_title

    self:refreshCost()
    self:refreshUpBtn()
end

function PetUpStagePanel:refreshCost()
    self.itemNotEnougths = {}
    local upgradeCost = self.petConfigData.upgradeCost
    for i = 1, 3 do
        local name = string.format("Item%d", i)
        local itemTr = self.itemParent:Find(name)

        if #upgradeCost >= i then
            local material = upgradeCost[i]
            local itemKey = tostring(material[1])

            local icon = itemTr:Find("Icon"):GetComponent(typeof(Image))
            local txt_count = itemTr:Find("txt_count"):GetComponent(typeof(Text))

            local itemData = AppServices.Meta:Category("ItemTemplate")[itemKey]
            icon.sprite = self:GetItemSprite(itemData.icon)

            local ownerCount = AppServices.User:GetItemAmount(tonumber(itemKey))
            txt_count.text = string.format("%d/%d", material[2], ownerCount)

            if material[2] > ownerCount then
                table.insert(self.itemNotEnougths, itemKey)
            end
        end

        local show = (#self.petConfigData.upgradeCost) >= i
        itemTr.gameObject:SetActive(show)
    end
end

function PetUpStagePanel:refreshUpBtn()
    local upType = self:EnableUp()
    self.btn_up_stage.gameObject:SetActive(upType == UpType.Enable)
    self.btn_disable.gameObject:SetActive(upType ~= UpType.Enable)

    local str = ""
    if upType == UpType.Item_Not_Enougth then
        str = "资源不足"
    elseif upType == UpType.Level_Not_Small_Than_Player then
        str = "需小于玩家等级"
    end

    self.txt_disable.text = str
end

function PetUpStagePanel:UpStageClick()
    PanelManager.closePanel(GlobalPanelEnum.PetUpStagePanel)
    AppServices.NetPetManager:SendPetLevelUp(self.pet.id, self.pet.level + 1)
end

function PetUpStagePanel:UpDisableClick()
    local upType = self:EnableUp()
    local msg = ""
    if upType == UpType.Level_Not_Small_Than_Player then
        msg = "需提升玩家等级"
    elseif upType == UpType.Item_Not_Enougth and self.itemNotEnougths then
        msg = "道具不足:"
        for _, v in pairs(self.itemNotEnougths) do
            msg = msg .. "  "..tostring(v)
        end
    end

    AppServices.UITextTip:Show(msg)
end

function PetUpStagePanel:GetItemSprite(spriteName)
    local atlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_ITEM_ICONS)
    local sprite = atlas:GetSprite(spriteName)
    return sprite
end

function PetUpStagePanel:EnableUp()
    local itemEnougth = AppServices.ItemCostManager:IsItemEnougth(self.petConfigData.upgradeCost)
    local playerLevel = AppServices.User:GetPlayerLevel()
    local petLevel = self.petConfigData.level

    if not itemEnougth then
        return UpType.Item_Not_Enougth
    end

    if petLevel >= playerLevel then
        return UpType.Level_Not_Small_Than_Player
    end
    return UpType.Enable
end

function PetUpStagePanel:Hide()

end

return PetUpStagePanel