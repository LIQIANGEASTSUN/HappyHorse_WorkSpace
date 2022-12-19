require "UI.OnHookBuild.OnHookBuildPanelNotificationEnum"
local OnHookBuildPanelProxy = require "UI.OnHookBuild.Model.OnHookBuildPanelProxy"

local OnHookBuildPanelMediator = MVCClass("OnHookBuildPanelMediator", BaseMediator)

---@type OnHookBuildPanel
local panel
local proxy

function OnHookBuildPanelMediator:ctor(...)
    OnHookBuildPanelMediator.super.ctor(self, ...)
    proxy = OnHookBuildPanelProxy.new()
end

function OnHookBuildPanelMediator:onRegister()
end

function OnHookBuildPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function OnHookBuildPanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        OnHookBuildPanelNotificationEnum.Click_btn_close
    }
end

function OnHookBuildPanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType() -- uncomment if need by yourself
    -- local body = notification:getBody() --message data  uncomment if need by yourself
    --insertHandleNotificationNames
    if (name == OnHookBuildPanelNotificationEnum.Click_btn_close) then
        PanelManager.closePanel(GlobalPanelEnum.OnHookBuildPanel, nil)
    end
end

-- function OnHookBuildPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function OnHookBuildPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function OnHookBuildPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function OnHookBuildPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function OnHookBuildPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function OnHookBuildPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function OnHookBuildPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function OnHookBuildPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function OnHookBuildPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function OnHookBuildPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function OnHookBuildPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return OnHookBuildPanelMediator
