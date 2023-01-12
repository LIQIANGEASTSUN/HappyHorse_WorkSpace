require "UI.AppUpdate.AppUpdateRewardPanel.AppUpdateRewardPanelNotificationEnum"
local AppUpdateRewardPanelProxy = require "UI.AppUpdate.AppUpdateRewardPanel.Model.AppUpdateRewardPanelProxy"

local AppUpdateRewardPanelMediator = MVCClass("AppUpdateRewardPanelMediator", BaseMediator)

local panel
local proxy

function AppUpdateRewardPanelMediator:ctor(...)
    AppUpdateRewardPanelMediator.super.ctor(self, ...)
    proxy = AppUpdateRewardPanelProxy.new()
end

function AppUpdateRewardPanelMediator:onRegister()
end

function AppUpdateRewardPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function AppUpdateRewardPanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        AppUpdateRewardPanelNotificationEnum.Click_btn_receive
    }
end

function AppUpdateRewardPanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType()
    -- local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == "") then
    elseif (name == AppUpdateRewardPanelNotificationEnum.Click_btn_receive) then
        self:GetReward()
    else
    end
end

function AppUpdateRewardPanelMediator:GetReward()
    local function FlyReward(flyBuilding)
        -- panel:FlyRewards(
        --     flyBuilding,
        --     function()
        --         self:closePanel()
        --     end
        -- )
        panel:IndependentFlyRewards()
        self:closePanel()
    end
    AppUpdateManager:GetAppUdpateReward(
        function(rewards)
            FlyReward(false)
        end,
        function()
            self:closePanel()
        end
    )
end

-- function AppUpdateRewardPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function AppUpdateRewardPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function AppUpdateRewardPanelMediator:onBeforeShowPanel()
    panel:SetRewards(self.arguments.rewards)
end
-- function AppUpdateRewardPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function AppUpdateRewardPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
function AppUpdateRewardPanelMediator:onAfterHidePanel()
    -- if self.rewardBuildingId then
    -- 	local scene = App:getRunningLuaScene()
    -- 	scene:CreateBuildingAgent(self.rewardBuildingId, function ()
    -- 		Runtime.InvokeCbk(self.arguments.finishCallback)
    -- 	end)
    -- else
    -- 	Runtime.InvokeCbk(self.arguments.finishCallback)
    -- end
    Runtime.InvokeCbk(self.arguments.finishCallback)
    self.arguments.finishCallback = nil
end

-- function AppUpdateRewardPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function AppUpdateRewardPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

function AppUpdateRewardPanelMediator:onBeforeDestroyPanel()
	--在被销毁之前，此时visible=false。
    Runtime.InvokeCbk(self.arguments.finishCallback)
    self.arguments.finishCallback = nil
end

-- function AppUpdateRewardPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function AppUpdateRewardPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return AppUpdateRewardPanelMediator
