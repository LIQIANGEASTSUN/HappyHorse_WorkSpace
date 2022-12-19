--insertWidgetsBegin
--    btn_close    btn_sure
--insertWidgetsEnd

--insertRequire
local _OnHookBuildPanelBase = require "UI.OnHookBuild.View.UI.Base._OnHookBuildPanelBase"

---@class OnHookBuildPanel:_OnHookBuildPanelBase
local OnHookBuildPanel = class(_OnHookBuildPanelBase)

function OnHookBuildPanel:ctor()
    self.pets = {}
end

function OnHookBuildPanel:onAfterBindView()
    self.pets = AppServices.User:GetPets()
end

function OnHookBuildPanel:refreshUI()
end

return OnHookBuildPanel
