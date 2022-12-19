--insertWidgetsBegin
--    text_continue    btn_hitLayer
--insertWidgetsEnd

--insertRequire
local _SkinRewardPreviewPanelBase = require "UI.Common.SkinRewardPreviewPanel.View.UI.Base._SkinRewardPreviewPanelBase"

---@class SkinRewardPreviewPanel:_SkinRewardPreviewPanelBase
local SkinRewardPreviewPanel = class(_SkinRewardPreviewPanelBase)

function SkinRewardPreviewPanel:ctor()
end

function SkinRewardPreviewPanel:onAfterBindView()
    local skinId = (self.arguments or {}).skinId
    if skinId then
        skinId = tostring(skinId)
        local skinMeta = AppServices.SkinLogic:GetSkinMeta(skinId)
        local isFemaleOrPet = skinMeta.type == SkinType.FemalePlayer or skinMeta.type == SkinType.Pet
        if isFemaleOrPet then
            self:ShowPlayerOrPetDress(skinId)
        else
            self:ShowDragonSkin(skinId)
        end
    end
end

function SkinRewardPreviewPanel:ShowPlayerOrPetDress(dressId)
    local meta = AppServices.SkinLogic:GetSkinMeta(dressId)
    local ModelPreviewItem = require("UI.Components.ModelPreviewItem")
    self.modelView = ModelPreviewItem.Create(self.dragonDress, 512)
    self.modelView:SetDragonModel(meta.model, nil, true)
    if self.arguments.modelPos then
        self.modelView:SetModelPosition(self.arguments.modelPos)
    end
    if meta.user == "Femaleplayer" then
        self.modelView:SetModelPosition(Vector3(-0.5, -2, 3))
    elseif meta.user == "Petdragon" then
        self.modelView:SetModelPosition(Vector3(-1, -1.2, 5))
    end
    self.modelView:SetPosition(Vector2(0, 0))
    self.modelView:SetRtSize(350)
    self.title.text = AppServices.Meta:GetItemName(dressId)
    self.desc.text = Runtime.Translate(AppServices.Meta:GetItemDesc(dressId))
    self.goQuality:SetActive(false)

    local trans = self.desc.transform
    local pos = trans.anchoredPosition
    pos.y = -215
    trans.anchoredPosition = pos
end

function SkinRewardPreviewPanel:ShowDragonSkin(skinId)
    local ModelPreviewItem = require("UI.Components.ModelPreviewItem")
    self.modelView = ModelPreviewItem.Create(self.dragonDress, 512)
    self.modelView:SetDragonModel("dragon_argil_lv1")
    self.modelView:SetPosition(Vector2(0, 0))
    self.modelView:SetDragonSkins({{tplId = skinId}}, true)
    self.modelView:SetRtSize(350)
    self.title.text = AppServices.Meta:GetItemName(skinId)
    self.desc.text = Runtime.Translate(AppServices.Meta:GetItemDesc(skinId))

    AppServices.SkinEquipManager:SetSkinQualityFlag(self.goQuality, skinId, true)
    local conf = AppServices.SkinLogic:GetSkinMeta(skinId)
    for i = 2, 3 do
        local id = conf.skill and conf.skill[i - 1] or nil
        local attInf = self.skills[i]
        if id then
            local skConfig = AppServices.SkinEquipManager:GetSkillConfig(id)
            attInf.txt.text = Runtime.Translate(skConfig.name)
            attInf.gameObject:SetActive(true)
            local spr = AppServices.ItemIcons:GetSpriteByName(skConfig.icon)
            UITool.AdaptImage(attInf.imgIcon, spr, 74)
        end
    end
    local attInf = self.skills[1]
    local spr = AppServices.ItemIcons:GetSpriteByName("equip_skill_dragon_energy")
    UITool.AdaptImage(attInf.imgIcon, spr, 74)
    local limit = conf.dragonEnergyLimit
    attInf.txt.text = string.format("%d-%d",limit[1], limit[2])
    attInf.gameObject:SetActive(true)
end

function SkinRewardPreviewPanel:DisposeModelView()
    self.modelView:Dispose()
end

function SkinRewardPreviewPanel:refreshUI()
end

return SkinRewardPreviewPanel
