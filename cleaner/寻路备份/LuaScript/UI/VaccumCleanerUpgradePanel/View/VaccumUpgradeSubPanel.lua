---@class VaccumUpgradeSubPanel
local VaccumUpgradeSubPanel = {
    alive = true
}

function VaccumUpgradeSubPanel:Init(gameObject)
    self.gameObject = gameObject
    local bg = find_component(self.gameObject, "bg")
    local title = find_component(bg, "txt_title")
    self.txtLvFrom = find_component(bg, "txtLvFrom", Text)
    self.txtLvTo = find_component(bg, "txtLvTo", Text)
    local txtUpgrade = find_component(bg, "txtUpgrade") --desc
    local txtRangeFrom = find_component(bg, "txtRangeFrom")
    local txtDisFrom = find_component(bg, "txtDisFrom")
    local txtVacFrom = find_component(bg, "txtVacFrom")
    self.txtRangeTo = find_component(bg, "txtRangeTo", Text)
    self.txtDisTo = find_component(bg, "txtDisTo", Text)
    self.txtVacTo = find_component(bg, "txtVacTo", Text)

    local btnUpgrade = find_component(bg, "btnUpgrade")
    self.iconUpgrade = find_component(btnUpgrade, "icon", Image)
    self.txtUpgradeCost = find_component(btnUpgrade, "Text", Text)
    Util.UGUI_AddButtonListener(btnUpgrade, self.OnClickUpgrade, self)
    Util.UGUI_AddEventListener(
        self.gameObject,
        UIEventName.onClick,
        function()
            self:Hide()
        end
    )
end

function VaccumUpgradeSubPanel:SetData(info)
    if not self.alive then
        return
    end
    self.showInfo = info
    local curMeta = AppServices.Meta:GetVaccumMeta(info.type, info.level)
    local nextMeta = AppServices.Meta:GetVaccumMeta(info.type, info.level + 1)
    self.txtLvFrom.text = "lv." .. curMeta.level
    self.txtLvTo.text = "lv." .. nextMeta.level

    local formatStr = "%s <color=#30CA00>+%s</color>"
    local delta = nextMeta.xValue - curMeta.xValue
    if delta > 0 then
        self.txtRangeTo.text = string.format(formatStr, tostring(nextMeta.xValue), tostring(delta))
    else
        self.txtRangeTo.text = nextMeta.xValue
    end
    delta = nextMeta.scaleValue - curMeta.scaleValue
    if delta > 0 then
        self.txtDisTo.text = string.format(formatStr, tostring(nextMeta.scaleValue), tostring(delta))
    else
        self.txtDisTo.text = nextMeta.scaleValue
    end
    delta = nextMeta.inhaleLevel - curMeta.inhaleLevel
    if delta > 0 then
        self.txtVacTo.text = string.format(formatStr, tostring(nextMeta.inhaleLevel), tostring(delta))
    else
        self.txtVacTo.text = nextMeta.inhaleLevel
    end

    local cost = curMeta.levelUpCost[1]
    self.costId = cost[1]
    self.costCnt = cost[2]
    self.iconUpgrade.sprite = AppServices.ItemIcons:GetSprite(self.costId)
    self.txtUpgradeCost.text = self.costCnt
    self:Show()
end

function VaccumUpgradeSubPanel:Show()
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetActive(true)
    end
end
function VaccumUpgradeSubPanel:Hide()
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetActive(false)
    end
end

function VaccumUpgradeSubPanel:OnClickUpgrade()
    AppServices.NetEquipManager:SendEquipLvUp(self.showInfo)
    sendNotification(VaccumCleanerUpgradePanelNotificationEnum.VaccumCleanerUpgradePanel_OnClose)
end

function VaccumUpgradeSubPanel:Destroy()
    self.alive = nil
    self.gameObject = nil
    self.txtUpgradeCost = nil
    self.txtLvFrom = nil
    self.txtLvTo = nil
    self.txtRangeTo = nil
    self.txtDisTo = nil
    self.txtVacTo = nil
    self.iconUpgrade = nil
end

return VaccumUpgradeSubPanel
