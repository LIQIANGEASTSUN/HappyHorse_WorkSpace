--insertWidgetsBegin
--	btn_zh	btn_rs	btn_en	btn_fr
--	btn_close
--insertWidgetsEnd

--insertRequire
local _ChooseLanguagePanelBase = require "UI.Settings.ChooseLanguagePanel.View.UI.Base._ChooseLanguagePanelBase"

local ChooseLanguagePanel = class(_ChooseLanguagePanelBase)

function ChooseLanguagePanel:ctor()

end

function ChooseLanguagePanel:onAfterBindView()
end

-- local filename = "lang.dat"
function ChooseLanguagePanel:refreshUI()
    local current = AppServices.User:GetLanguage()
    self.currentLanguage = current
    self:OnSelectLanguage(current)
end

function ChooseLanguagePanel:OnSelectLanguage(language)
    for key, value in pairs(self.buttons) do
        value:OnCheck(language)
    end
end

return ChooseLanguagePanel
