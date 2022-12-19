require "UI.Settings.TownNamePanel.TownNamePanelNotificationEnum"
local TownNamePanelProxy = require "UI.Settings.TownNamePanel.Model.TownNamePanelProxy"

local TownNamePanelMediator = MVCClass("TownNamePanelMediator", BaseMediator)

local panel
local proxy

function TownNamePanelMediator:ctor(...)
    TownNamePanelMediator.super.ctor(self, ...)
    proxy = TownNamePanelProxy.new()
end

function TownNamePanelMediator:onRegister()
end

function TownNamePanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
    if self.arguments then
        self.callback = self.arguments.callback
        self.isFirstTime = self.arguments.isFirstTime
    end
end

function TownNamePanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        TownNamePanelNotificationEnum.Click_btn_ok,
        TownNamePanelNotificationEnum.Close_Panel
    }
end

function TownNamePanelMediator:handleNotification(notification)
    local name = notification:getName()
    --local type = notification:getType()
    --local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == "") then
    elseif (name == TownNamePanelNotificationEnum.Click_btn_ok) then
        local function finishCB()
            Runtime.InvokeCbk(self.callback)
            self:closePanel()
        end

        local newName = panel.input_name.text
        if newName == AppServices.User:GetNickName() then
            self:closePanel()
            return
        end

        DcDelegates:Log(SDK_EVENT.modify_name, Util.AddUserStatsParams({old = AppServices.User:GetNickName(), new = newName}))
        AppServices.User:ModifyNickName(newName, finishCB)
	elseif name == TownNamePanelNotificationEnum.Close_Panel then
        self:closePanel()
	end
end

function TownNamePanelMediator:onAfterShowPanel()
    --在第一次显示之后，此时visible=true。
    panel.input_name:Select()
end

-- function TownNamePanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function TownNamePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end
--[[
function TownNamePanelMediator:onBeforeShowPanel()
    --在第一次显示之前，此时visible=false。
    panel:refreshUI()
    if not self.isFirstTime then
        panel.input_name.text = AppServices.User:GetNickName()
    else
        panel:PreventShowButtonsOnClose()
    end
end


function TownNamePanelMediator:onBeforeHidePanel()
    panel:BeforeHide()
end
]]
--function TownNamePanelMediator:onAfterHidePanel()
--	--在被隐藏之后(FadeOut完成后)，此时visible=false。
--
--end

-- function TownNamePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function TownNamePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function TownNamePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function TownNamePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function TownNamePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return TownNamePanelMediator
