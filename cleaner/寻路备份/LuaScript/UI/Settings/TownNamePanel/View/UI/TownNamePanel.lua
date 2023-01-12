--insertWidgetsBegin
--	text_title	btn_ok
--insertWidgetsEnd

--insertRequire
local _TownNamePanelBase = require "UI.Settings.TownNamePanel.View.UI.Base._TownNamePanelBase"

local TownNamePanel = class(_TownNamePanelBase)

function TownNamePanel:ctor()

end

function TownNamePanel:onAfterBindView()
    self.text_title.text = Runtime.Translate("ui.town_name_panel.title")
    self.input_name.text = AppServices.User:GetNickName()
end

return TownNamePanel
