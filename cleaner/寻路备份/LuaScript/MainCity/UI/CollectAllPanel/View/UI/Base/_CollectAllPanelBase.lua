--insertRequire
---@class _CollectAllPanelBase:BasePanel
local _CollectAllPanelBase = class(BasePanel)

function _CollectAllPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
end

function _CollectAllPanelBase:setProxy(proxy)
    self.proxy = proxy
end

function _CollectAllPanelBase:bindView()
    if Runtime.CSValid(self.gameObject) then
        self:bindBtnCallback()
    end
end

function _CollectAllPanelBase:bindBtnCallback()
    self.onClick_btn_hitLayer = function()
        sendNotification(CollectAllPanelNotificationEnum.Click_btn_hitLayer)
    end

    --[[local function OnClick_btn_hitLayer(go)
        if (self.onClick_btn_hitLayer ~= nil) then
            self.onClick_btn_hitLayer()
        end
    end--]]

    --Util.UGUI_AddEventListener(self.gameObject, "onClick", OnClick_btn_hitLayer)
end

--insertSetTxt

return _CollectAllPanelBase
