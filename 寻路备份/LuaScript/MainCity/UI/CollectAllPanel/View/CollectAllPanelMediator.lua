require "MainCity.UI.CollectAllPanel.CollectAllPanelNotificationEnum"
local CollectAllPanelProxy = require "MainCity.UI.CollectAllPanel.Model.CollectAllPanelProxy"
---@class CollectAllPanelMediator:BaseMediator
local CollectAllPanelMediator = MVCClass("CollectAllPanelMediator", BaseMediator)
---@type CollectAllPanel
local panel
local proxy

function CollectAllPanelMediator:ctor(...)
    CollectAllPanelMediator.super.ctor(self, ...)
    proxy = CollectAllPanelProxy.new()
end

function CollectAllPanelMediator:onRegister()
end

function CollectAllPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
    self.isInAnim = false
    -- panel:SetHideTopIconType(TopIconHideType.stayDiamondCoinIcon)
    -- if App.scene:IsMainCity() then
    --     App.scene:HideAllIcons()
    -- end
end

function CollectAllPanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        CollectAllPanelNotificationEnum.Click_btn_hitLayer
    }
end

function CollectAllPanelMediator:handleNotification(notification)
    local name = notification:getName()
    --insertHandleNotificationNames
    if name == CollectAllPanelNotificationEnum.Click_btn_hitLayer then
        self:HandleClick()
    end
end

function CollectAllPanelMediator:HandleClick()
    if self.isInAnim then
        return
    end
    self.isInAnim = true
    PanelManager.closePanel(panel.panelVO)
    -- if App.scene:IsMainCity() then
    --     App.scene:ShowAllIcons()
    -- end
end

-- function CollectAllPanelMediator:onBeforeLoadAssets()
--     -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
--     -- Send Request To Server
-- end

--function CollectAllPanelMediator:onBeforeShowPanel()
--     --在第一次显示之前，此时visible=false。
--end

function CollectAllPanelMediator:onAfterShowPanel()
    --self.isInAnim = false
    -- local count = App.globalFlags:Get("CollectAllPanelOpenCount", 0)
    -- App.globalFlags:Set("CollectAllPanelOpenCount", count + 1)
    --[[for i = 1, 3 do
        if not App.mapGuideManager:HasComplete("CollectAllPanelPop_" .. i) then
            App.mapGuideManager:MarkGuideComplete("CollectAllPanelPop_" .. i)
            break
        end
    end--]]
    if self.scheduler then
        WaitExtension.CancelTimeout(self.scheduler)
        self.scheduler = nil
    end
    local shakeAppearTime = tonumber(AppServices.Meta.metas.ConfigTemplate["shakeAppearTime"].value)
    self.scheduler = WaitExtension.SetTimeout(
    function()
        self.scheduler = nil
        self:HandleClick()
    end,
    shakeAppearTime
    )
    Util.BlockAll(shakeAppearTime, "CollectAllPanel")
end

-- function CollectAllPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function CollectAllPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function CollectAllPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function CollectAllPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

function CollectAllPanelMediator:onAfterDestroyPanel()
    --在被销毁之前，此时visible=false。
    if self.scheduler then
        WaitExtension.CancelTimeout(self.scheduler)
        self.scheduler = nil
    end

    local shakeButton = App.scene:GetWidget(CONST.MAINUI.ICONS.ShakeButton)
    if shakeButton then
        shakeButton:StopHit()
    end
end

-- function CollectAllPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function CollectAllPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return CollectAllPanelMediator
