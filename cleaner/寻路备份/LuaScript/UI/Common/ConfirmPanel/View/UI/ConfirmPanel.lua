--insertWidgetsBegin
--insertWidgetsEnd

--insertRequire
local _ConfirmPanelBase = require "UI.Common.ConfirmPanel.View.UI.Base._ConfirmPanelBase"

---@class ConfirmPanel:_ConfirmPanelBase
local ConfirmPanel = class(_ConfirmPanelBase)

function ConfirmPanel:ctor()

end

function ConfirmPanel:onAfterBindView()
    local inf = self.arguments
    self.txtTittle.text = Runtime.Translate(inf.tittle or "")
    self.txtContent.text = Runtime.Translate(inf.content or "")
    self.txtBtnOk.text = Runtime.Translate(inf.ok or "")
    self.txtBtnCancel.text = Runtime.Translate(inf.cancel or "")
    if inf.sprite then
        local path = string.format("Prefab/RuntimeIcons/BoxKeysObstacleIcons/%s.png",inf.sprite)
        local function onLoaded(spr)
            if spr then
                local rect = spr.rect
                local ratio = rect.width/rect.height
                self.imgIcon.sprite = spr
                self.imgIcon.transform.sizeDelta = Vector2(170,170/ratio)
            end
        end
        AppServices.ItemIcons:LoadSpriteAsync(path,onLoaded)
    end
    Util.UGUI_AddButtonListener(self.btnOk, function ()
        sendNotification(ConfirmPanelNotificationEnum.ClickOk, inf.onConfirm)
    end)
    Util.UGUI_AddButtonListener(self.btnCancel, function ()
        sendNotification(ConfirmPanelNotificationEnum.ClickCancel, inf.onCancel)
    end)
    Util.UGUI_AddButtonListener(self.btnClose, function ()
        sendNotification(ConfirmPanelNotificationEnum.Close)
    end)
end

function ConfirmPanel:refreshUI()

end

return ConfirmPanel
