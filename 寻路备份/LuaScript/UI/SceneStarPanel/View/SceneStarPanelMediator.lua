require "UI.SceneStarPanel.SceneStarPanelNotificationEnum"
local SceneStarPanelProxy = require "UI.SceneStarPanel.Model.SceneStarPanelProxy"

local SceneStarPanelMediator = MVCClass('SceneStarPanelMediator', BaseMediator)

---@type SceneStarPanel
local panel
local proxy

function SceneStarPanelMediator:ctor(...)
	SceneStarPanelMediator.super.ctor(self,...)
	proxy = SceneStarPanelProxy.new()
	MessageDispatcher:AddMessageListener(MessageType.Task_OnSubTaskFinish, self.OnTaskFinish, self)
	MessageDispatcher:AddMessageListener(MessageType.Task_OnSubTaskAddProgress, self.OnTaskProgress, self)
end

function SceneStarPanelMediator:onRegister()
end

function SceneStarPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function SceneStarPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
        SceneStarPanelNotificationEnum.Click_btn_get1,
        SceneStarPanelNotificationEnum.Click_btn_get2,
        SceneStarPanelNotificationEnum.Click_btn_close,
		SceneStarPanelNotificationEnum.Click_SceneStarPanel_btn_rewardTip,
		SceneStarPanelNotificationEnum.Click_btn_rewardMask,
		SceneStarPanelNotificationEnum.Click_btn_ok,
	}
end

function SceneStarPanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
	if(name ==SceneStarPanelNotificationEnum.Click_btn_get1) then
	elseif(name == SceneStarPanelNotificationEnum.Click_btn_get2) then
	elseif(name == SceneStarPanelNotificationEnum.Click_btn_close) then
		PanelManager.closePanel(GlobalPanelEnum.SceneStarPanel)
	elseif(name == SceneStarPanelNotificationEnum.Click_SceneStarPanel_btn_rewardTip) then
		panel.c2_rewardRoot:SetActive(true)
		panel.btn_rewardMask.gameObject:SetActive(true)
	elseif (name == SceneStarPanelNotificationEnum.Click_btn_rewardMask) then
		panel.c2_rewardRoot:SetActive(false)
		panel.btn_rewardMask.gameObject:SetActive(false)
	elseif (name == SceneStarPanelNotificationEnum.Click_btn_ok) then
		PanelManager.closePanel(GlobalPanelEnum.SceneStarPanel)
		local processor = require "UI.HomeScene.WorldMapPanel.OpenWorldMapProcessor"
        processor.Start()
	end
end

-- function SceneStarPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function SceneStarPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function SceneStarPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
--[[local function TryGetStarTimeReward()
	local sceneId = App.scene:GetCurrentSceneId()
	if AppServices.MapStarManager:CanGetLimitTimeReward(sceneId) then
		AppServices.MapStarManager:UpdateLimitStarReward(sceneId)
		panel.boxRoot:SetActive(true)
		--AppServices.MapStarManager:GetStarTimeReward(sceneId, function(rewards)
		local sceneCfg = AppServices.Meta:GetSceneCfg(sceneId)
			local flyRewards = {}
			for _, item in ipairs(sceneCfg.timeLimitedReward) do
				table.insert(
				flyRewards,
				{ItemId = item[1], Amount = item[2]}
				)
			end
			AppServices.RewardAnimation.FlyReward(flyRewards, panel.go_flyRewardPos.transform.position, 1.1, 0.2, 1.2, false, 1, Ease.InCirc)
			local limitTime = AppServices.MapStarManager:GetLimitTime(sceneId) / 1000
			local difftime = math.floor(limitTime - TimeUtil.ServerTime())
			panel:SetTimeRewardState(sceneId, difftime)
		--end)
	end
	local sceneId = App.scene:GetCurrentSceneId()
	if AppServices.MapStarManager:GetSceneStar(sceneId) == SCENE_STAR_NUM then
		AppServices.MapStarManager:UpdateLimitStarReward(sceneId)
		panel.boxRoot:SetActive(true)
	end
end--]]
function SceneStarPanelMediator:onAfterShowPanel()
	local sceneId = App.scene:GetCurrentSceneId()
	local mapStarManager = AppServices.MapStarManager
	local starIndexAry = {}
	for i = 1, SCENE_STAR_NUM do
		if mapStarManager:CanGetStarReward(sceneId, i) then
			table.insert(starIndexAry, i)
		end
	end
	self:showReward(starIndexAry)
end

function SceneStarPanelMediator:showReward(starIndexAry)
-- 	--在第一次显示之后，此时visible=true。
	local sceneId = App.scene:GetCurrentSceneId()
	local mapStarManager = AppServices.MapStarManager

	if #starIndexAry > 0 then
		local flyRewards = {}

		local flyRewardFunc = function()
			if Runtime.CSNull(panel.gameObject) then
				return
			end
			Util.BlockAll(10, "flystarReward")
			---对勾

			---飞星
			for _, index in ipairs(starIndexAry) do
				--[[local star = panel.taskAry[index]
				if star ~= nil then
					star:SetGetReward()
				end--]]
				panel:ShowFlyStar(index)
			end
			---刷进度，
			panel:SetDelay(function()
				if Runtime.CSValid(panel.img_starProcess) then
					panel.text_starCount.text = mapStarManager:GetSceneStar(sceneId) .. "/" .. SCENE_STAR_NUM
					panel.img_starProcess:DOFillAmount(mapStarManager:GetSceneStar(sceneId) / SCENE_STAR_NUM, 0.5)
				end
			end, 1.2)
			---飞奖励
			local taskConfig = mapStarManager:GetSceneTaskConfig(sceneId)
			for _, index in ipairs(starIndexAry) do
				local taskCfg = taskConfig[index]
				for rewardIndex, reward in ipairs(taskCfg.rewards) do
					if panel.taskAry[index] ~= nil and panel.taskAry[index].rewardAry[rewardIndex] ~= nil then
						local go_done = panel.taskAry[index].rewardAry[rewardIndex].go_done
						table.insert(flyRewards, {ItemId = reward.ItemId, Amount = reward.Amount, position = panel.taskAry[index].rewardAry[rewardIndex].img_icon.transform.position, beforeFly = function()
							go_done:SetActive(true)
						end })
					end
				end
			end
			local interval = 0.2
			local addDelay = interval * #flyRewards
			panel:SetDelay(function()
				Util.BlockAll(0, "flystarReward")
				--PanelManager.showPanel(GlobalPanelEnum.SimpleRewardPanel,{rewards = flyRewards, callback = TryGetStarTimeReward})
				AppServices.RewardAnimation.FlyReward(flyRewards, panel.go_flyRewardPos.transform.position, 0, 0.2, 1.2, false, 1, Ease.InCirc)
			end, 1.2)

			if AppServices.MapStarManager:GetSceneStar(sceneId) == SCENE_STAR_NUM then
				Util.BlockAll(20, "show3starAward")
				---面板下滑
				panel:SetDelay(function()
					local animtor = panel.c2_stars:GetComponent(typeof(Animator))
					animtor:SetTrigger("repairing")
					--panel.c2_stars.transform:DOAnchorPosY(-700, 1)
				end, 2.4 + addDelay)
				---出地图信息
				panel:SetDelay(function()
					panel:ShowAllDoneMapInfo()
				end, 3.3 + addDelay)
				local showRewardDur = 0.3
				if AppServices.MapStarManager:CanGetLimitTimeReward(sceneId) then
					---飞宝箱
					panel:SetDelay(function ()
						panel.boxRoot:SetActive(true)
					end, 3.8 + addDelay)
					---显示奖励
					local goAry = panel:ShowAllDoneReward()
					interval = 0.2
					panel:SetDelay(function()
						panel.items:SetActive(true)
						AppServices.MapStarManager:UpdateLimitStarReward(sceneId)
					end, 6.1 + addDelay)
					for i, go in ipairs(goAry) do
						panel:SetDelay(function()
							go.transform:DOScale(1, 0.5)
						end, 6.1 + addDelay + interval * i)
					end
					showRewardDur = 2.8 + interval * #goAry
				end
				---出按钮
				panel:SetDelay(function()
					Util.BlockAll(0, "show3starAward")
					panel.btn_ok:SetActive(true)
				end, 3.8 + addDelay + showRewardDur)
			end
		end

		if AppServices.MapStarManager:GetSceneStar(sceneId) == SCENE_STAR_NUM then
			AppServices.MapStarManager:UpdateStarState(sceneId, starIndexAry)
			flyRewardFunc()
		else
			mapStarManager:GetStarReward(sceneId, starIndexAry, function(rewards)
				flyRewardFunc()
			end)
		end
	else
		--PanelManager.showPanel(GlobalPanelEnum.SimpleRewardPanel,{rewards = {{ItemId = ItemId.DIAMOND, Amount = 99}}, callback = TryGetStarTimeReward})
		-- TryGetStarTimeReward()
	end
end

function SceneStarPanelMediator:OnTaskFinish(taskKind, taskId, sceneId)
	if taskKind ~= TaskKind.MapStar then
		return
	end
	if sceneId ~= App.scene:GetCurrentSceneId() then
		return
	end
	local taskConfig = AppServices.MapStarManager:GetSceneTaskConfig(sceneId)
	for index = 1, SCENE_STAR_NUM do
		local taskCfg = taskConfig[index]
		for _, cfg in ipairs(taskCfg.taskConfigs) do
			if taskId == cfg.id then
				panel:RefreshTask(index, taskId)
				if AppServices.MapStarManager:CanGetStarReward(sceneId, index) then
					self:showReward({index})
				end
			end
		end
	end
end

function SceneStarPanelMediator:OnTaskProgress(taskKind, taskId, sceneId)
	if taskKind ~= TaskKind.MapStar then
		return
	end
	if sceneId ~= App.scene:GetCurrentSceneId() then
		return
	end
	local taskConfig = AppServices.MapStarManager:GetSceneTaskConfig(sceneId)
	for index = 1, SCENE_STAR_NUM do
		local taskCfg = taskConfig[index]
		for _, cfg in ipairs(taskCfg.taskConfigs) do
			if taskId == cfg.id then
				panel:RefreshTask(index, taskId)
			end
		end
	end
end

-- function SceneStarPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function SceneStarPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function SceneStarPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function SceneStarPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

 function SceneStarPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
	 MessageDispatcher:RemoveMessageListener(MessageType.Task_OnSubTaskFinish, self.OnTaskFinish, self)
	 MessageDispatcher:RemoveMessageListener(MessageType.Task_OnSubTaskAddProgress, self.OnTaskProgress, self)
	 panel:Release()
 end

-- function SceneStarPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function SceneStarPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return SceneStarPanelMediator
