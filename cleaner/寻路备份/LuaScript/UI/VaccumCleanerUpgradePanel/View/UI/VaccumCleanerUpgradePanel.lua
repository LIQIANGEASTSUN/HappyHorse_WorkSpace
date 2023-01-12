--insertWidgetsBegin
--insertWidgetsEnd

--insertRequire
local _VaccumCleanerUpgradePanelBase =
    require "UI.VaccumCleanerUpgradePanel.View.UI.Base._VaccumCleanerUpgradePanelBase"

---@class VaccumCleanerUpgradePanel:_VaccumCleanerUpgradePanelBase
local VaccumCleanerUpgradePanel = class(_VaccumCleanerUpgradePanelBase)

function VaccumCleanerUpgradePanel:ctor()
    ---@type DEquip
    self.equipInfo = AppServices.User:GetVaccumInfo() or {}
    self.equips = {}
    local equips = AppServices.User:GetVaccumInfos()
    local index = 0
    for _, equip in pairs(equips) do
        index = index + 1
        if equip.up == 1 then
            self.showIndex = index
        end
        table.insert(self.equips, equip)
    end
    self.showIndex = self.showIndex or 1
end

function VaccumCleanerUpgradePanel:GetMeta(info)
    local meta = AppServices.Meta:GetVaccumMeta(info.type, info.level + 1)
    return meta
end
function VaccumCleanerUpgradePanel:GetNextLevelMeta(info)
    local nextMeta = AppServices.Meta:GetVaccumMeta(info.type, info.level + 1)
    return nextMeta
end

function VaccumCleanerUpgradePanel:onAfterBindView()
    self:ShowVaccum(self.showIndex)
end

function VaccumCleanerUpgradePanel:ShowUpgradePanel()
    if not self.upgradeSubPanel then
        local subPanelPath = "Prefab/UI/VaccumCleanerUpgradePanel/UpgradeSubPanel.prefab"
        local gameObject = BResource.InstantiateFromAssetName(subPanelPath, self.gameObject, false)
        self.upgradeSubPanel = include("UI.VaccumCleanerUpgradePanel.View.VaccumUpgradeSubPanel")
        self.upgradeSubPanel:Init(gameObject)
    end
    self.upgradeSubPanel:SetData(self.showInfo)
end

function VaccumCleanerUpgradePanel:ChangeSelection(add)
    self.showIndex = self.showIndex + add
    if self.showIndex < 1 then
        self.showIndex = self.showIndex + #self.equips
    elseif self.showIndex > #self.equips then
        self.showIndex = self.showIndex - #self.equips
    end
    self:ShowVaccum(self.showIndex)
end

function VaccumCleanerUpgradePanel:ShowVaccum(index)
    self.showInfo = self.equips[index]
    local meta = AppServices.Meta:GetVaccumMeta(self.showInfo.type, self.showInfo.level)
    self.txtRangeTo.text = meta.xValue
    self.txtDisTo.text = meta.scaleValue
    self.txtVacTo.text = meta.inhaleLevel
    self.btnEquip.interactable = self.showInfo.up == 0
    local nextMeta = self:GetNextLevelMeta(self.showInfo)
    self.btnUpgrade.interactable = nextMeta ~= nil

    local modelName = meta.model
    if string.isEmpty(meta.model) then
        modelName = "VaccumCleaner"
    end
    local modelPath = string.format("Prefab/Art/Characters/%s.prefab", modelName)
    self:ShowModel(modelPath)
end

function VaccumCleanerUpgradePanel:ShowModel(modelPath)
    if not self.modelView then
        local ModelPreviewItem = include("UI.Components.ModelPreviewItem")
        ---@type ModelPreviewItem
        self.modelView = ModelPreviewItem.Create(self.image, 512, true)
        self.modelView:SetRtSize(self.image.transform.sizeDelta.x)
        self.modelView:SetCameraFov(25)
    end
    self.modelView:SetModel(modelPath)
end

function VaccumCleanerUpgradePanel:Equip()
    self.equipInfo.up = 0
    self.showInfo.up = 1
    AppServices.User:SetEquipInfo(self.showInfo)
    self.equipInfo = self.showInfo
    self:ShowVaccum(self.showIndex)
    --发消息
    AppServices.NetEquipManager:SendEquip(self.showInfo)
    MessageDispatcher:SendMessage(MessageType.VaccumChanged, self.showInfo)
end

function VaccumCleanerUpgradePanel:refreshUI()
end

function VaccumCleanerUpgradePanel:DisposeGameObject()
    _VaccumCleanerUpgradePanelBase.DisposeGameObject(self)
    if self.modelView then
        self.modelView:Dispose()
        self.modelView = nil
    end
end

return VaccumCleanerUpgradePanel
