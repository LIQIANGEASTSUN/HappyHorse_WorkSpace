--insertWidgetsBegin
--    btn_panel
--insertWidgetsEnd

--insertRequire
local _DynamicUpdatePanelBase = require "UI.DynamicUpdatePanel.View.UI.Base._DynamicUpdatePanelBase"

---@class DynamicUpdatePanel:_DynamicUpdatePanelBase
local DynamicUpdatePanel = class(_DynamicUpdatePanelBase)

function DynamicUpdatePanel:ctor()

end

function DynamicUpdatePanel:onAfterBindView()
    self:setProgress(self.arguments.value or 0.04, 0.04)
    self:setInfo(self.arguments.content or "")
end

function DynamicUpdatePanel:refreshUI()
end

function DynamicUpdatePanel:setInfo(val)
    if Runtime.CSNull(self.lbInfo) then return end
    self.lbInfo.text = string.format("%s %s", Runtime.Translate("UI_download_point"), val or "")
end

function DynamicUpdatePanel:setProgress(val)
    if Runtime.CSNull(self.slider) then return end

    local function updateCallback(value)
        self.slider.value = math.max(value, 0.04)
    end

    local function completeCallback()
        if self.floatSmoothTweener ~= nil then
            self.floatSmoothTweener:Kill()
            self.floatSmoothTweener = nil
        end
    end

    completeCallback()
    self.floatSmoothTweener = LuaHelper.FloatSmooth(self.slider.value, val, 0.3, updateCallback, completeCallback)
end

return DynamicUpdatePanel
