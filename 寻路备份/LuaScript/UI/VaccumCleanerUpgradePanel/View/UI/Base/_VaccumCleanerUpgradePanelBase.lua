--insertRequire

---@class _VaccumCleanerUpgradePanelBase:BasePanel
local _VaccumCleanerUpgradePanelBase = class(BasePanel)

function _VaccumCleanerUpgradePanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
end

function _VaccumCleanerUpgradePanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _VaccumCleanerUpgradePanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        local title = find_component(self.gameObject, "txt_title")
        local txtAttribute = find_component(self.gameObject, "txtAttribute")
        local txtRangeFrom = find_component(self.gameObject, "txtRangeFrom")
        local txtDisFrom = find_component(self.gameObject, "txtDisFrom")
        local txtVacFrom = find_component(self.gameObject, "txtVacFrom")
        self.txtRangeTo = find_component(self.gameObject, "txtRangeTo", Text)
        self.txtDisTo = find_component(self.gameObject, "txtDisTo", Text)
        self.txtVacTo = find_component(self.gameObject, "txtVacTo", Text)

        self.btnEquip = find_component(self.gameObject, "btnEquip", Button)
        local txtEquip = find_component(self.btnEquip, "Text")
        self.btnUpgrade = find_component(self.gameObject, "btnUpgrade", Button)
        local txtUpgrade = find_component(self.btnUpgrade, "Text")
        self.btnLeft = find_component(self.gameObject, "btnLeft")
        self.btnRight = find_component(self.gameObject, "btnRight")
        local btnClose = find_component(self.gameObject, "btnClose")
        self.image = find_component(self.gameObject, "RawImage", RawImage)

        --insertInitComp
        --insertOnClick
        local function onClose()
            sendNotification(VaccumCleanerUpgradePanelNotificationEnum.VaccumCleanerUpgradePanel_OnClose)
        end
        Util.UGUI_AddButtonListener(btnClose, onClose)
        Util.UGUI_AddButtonListener(
            self.btnEquip,
            function()
                self:Equip()
            end
        )
        Util.UGUI_AddButtonListener(
            self.btnUpgrade,
            function()
                self:ShowUpgradePanel()
            end
        )
        Util.UGUI_AddButtonListener(
            self.btnLeft,
            function()
                self:ChangeSelection(-1)
            end
        )
        Util.UGUI_AddButtonListener(
            self.btnRight,
            function()
                self:ChangeSelection(1)
            end
        )
    --insertDeclareBtn
    end
end

--insertSetTxt

return _VaccumCleanerUpgradePanelBase
