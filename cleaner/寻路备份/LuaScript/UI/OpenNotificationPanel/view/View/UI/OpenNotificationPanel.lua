--insertWidgetsBegin
--	img_board	img_tile_board	text_title	btn_open
--	btn_cancel	btn_close	img_bg	text_desc
--insertWidgetsEnd

--insertRequire
local _OpenNotificationPanelBase = require "UI.OpenNotificationPanel.view.View.UI.Base._OpenNotificationPanelBase"

local OpenNotificationPanel = class(_OpenNotificationPanelBase)

function OpenNotificationPanel:ctor()

end

function OpenNotificationPanel:onAfterBindView()
    local type = self.arguments.type or 0
    self.text_title.text = Runtime.Translate("ui.push_title")
    self.text_desc.text = Runtime.Translate("ui.push_des_" .. type)
    local openBtnText = self.btn_open:GetComponentInChildren(typeof(Text))
    openBtnText.text = Runtime.Translate("ui.push_agree")
    local cancelBtnText = self.btn_cancel:GetComponentInChildren(typeof(Text))
    cancelBtnText.text = Runtime.Translate("ui.push_refuse")
end

function OpenNotificationPanel:refreshUI()

end

return OpenNotificationPanel
