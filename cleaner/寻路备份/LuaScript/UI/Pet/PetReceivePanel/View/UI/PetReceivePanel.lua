--insertWidgetsBegin
--    btn_close
--insertWidgetsEnd

--insertRequire
---@type PetTemplateTool
local PetTemplateTool = require "Cleaner.Entity.Pet.PetTemplateTool"

local _PetReceivePanelBase = require "UI.Pet.PetReceivePanel.View.UI.Base._PetReceivePanelBase"

---@type PetReceiveEnum
local PetReceiveEnum = require "UI.Pet.PetReceivePanel.View.UI.PetReceiveEnum"

---@class PetReceivePanel:_PetReceivePanelBase
local PetReceivePanel = class(_PetReceivePanelBase)

function PetReceivePanel:ctor()

end

function PetReceivePanel:onAfterBindView()

end

function PetReceivePanel:SetArguments(arguments)
    self.petId = arguments.petId
    self.receiveType = arguments.receiveType
end

function PetReceivePanel:refreshUI()
    self.pet = AppServices.User:GetPet(self.petId)
    self:CheckReceiveType()
    self:refreshTitle()

    local key = PetTemplateTool:Getkey(self.pet.type, self.pet.level)
    -- self.icon =
    local data = AppServices.Meta:Category("PetTemplate")[tostring(key)]


    self.txt_hp = tostring(data.hp)

    local skillId = tostring(data.skillId)
    local skillData =  AppServices.Meta:Category("SkillTemplate")[skillId]
    self.txt_attack = tostring(skillData.attackPower)

    --self.btn_backpack
    self.btn_team.gameObject:SetActive(self.pet.up <= 0)
end

function PetReceivePanel:refreshTitle()
    local title = ""
    if self.receiveType == PetReceiveEnum.Reward then
        title = "新动物"
    elseif self.receiveType == PetReceiveEnum.UpLevel then
        title = "升级"
    elseif self.receiveType == PetReceiveEnum.UpStage then
        title = "升阶"
    end
    self.txt_title.text = title
end

function PetReceivePanel:CheckReceiveType()
    if self.receiveType == PetReceiveEnum.Reward then
        return
    end

    local key = PetTemplateTool:Getkey(self.pet.type, self.pet.level)
    local data = AppServices.Meta:Category("PetTemplate")[tostring(key)]

    self.icon.sprite = self:GetSprite(data.icon)

    local lastKey = PetTemplateTool:Getkey(self.pet.type, self.pet.level - 1)
    local lastData = AppServices.Meta:Category("PetTemplate")[tostring(lastKey)]

    if data.stage == lastData.stage then
        self.receiveType = PetReceiveEnum.UpLevel
    else
        self.receiveType = PetReceiveEnum.UpStage
    end
end

function PetReceivePanel:PetToBackpack()
    console.error("PetReceivePanel:PetToBackpack")
end

function PetReceivePanel:PetToTeam()
    console.error("PetReceivePanel:PetToTeam")
    PanelManager.closePanel(GlobalPanelEnum.PetReceivePanel, nil)

    local arguments = {editorPetId = self.pet.id}
    PanelManager.showPanel(GlobalPanelEnum.PetIllustratedPanel, arguments)
end

function PetReceivePanel:GetSprite(spriteName)
    self.petAtlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_ITEM_ICONS)
    local sprite = self.petAtlas:GetSprite(spriteName)
    return sprite
end

function PetReceivePanel:Hide()

end

return PetReceivePanel
