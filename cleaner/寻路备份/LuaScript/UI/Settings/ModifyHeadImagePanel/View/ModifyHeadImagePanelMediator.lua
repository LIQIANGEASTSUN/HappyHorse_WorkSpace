require "UI.Settings.ModifyHeadImagePanel.ModifyHeadImagePanelNotificationEnum"
local ModifyHeadImagePanelProxy = require "UI.Settings.ModifyHeadImagePanel.Model.ModifyHeadImagePanelProxy"
---@class ModifyHeadImagePanelMediator
local ModifyHeadImagePanelMediator = MVCClass('ModifyHeadImagePanelMediator', BaseMediator)

---@type ModifyHeadImagePanel
local panel
local proxy

function ModifyHeadImagePanelMediator:ctor(...)
	ModifyHeadImagePanelMediator.super.ctor(self,...)
	proxy = ModifyHeadImagePanelProxy.new()
	-- self.headImageNum = AppServices.Avatar:GetUsingAvatar()
	--console.error("self.headImageNum", self.headImageNum)
end

function ModifyHeadImagePanelMediator:onRegister()
end

function ModifyHeadImagePanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function ModifyHeadImagePanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
		ModifyHeadImagePanelNotificationEnum.Click_btn_close,
		ModifyHeadImagePanelNotificationEnum.Select_New_HeadImage,
		ModifyHeadImagePanelNotificationEnum.Select_New_AvatarFrame
	}
end

function ModifyHeadImagePanelMediator:handleNotification(notification)

	local name = notification:getName()
	--local type = notification:getType()
	local body = notification:getBody() --message data
	--insertHandleNotificationNames
	if(name == ModifyHeadImagePanelNotificationEnum.Click_btn_close) then
		local cd = CountDownLatch.Create(2, function()
			self:closePanel()
		end)
		local avatar = panel:GetChosenAvatar()
		local curAvatar = AppServices.Avatar:GetUsingAvatar()

		if avatar == curAvatar then
			cd:Done()
		elseif not table.exists(AppServices.Avatar:GetUnlockAvatars(), avatar) then
			cd:Done()
		else
			DcDelegates:Log(SDK_EVENT.modify_avatar, Util.AddUserStatsParams({old = AppServices.Avatar:GetUsingAvatar(), new = avatar}))
			AppServices.Avatar:ModifyAvatar(avatar, function()
				cd:Done()
			end)
		end

		local frame = panel:GetChosenFrame()
		local curFrame = AppServices.AvatarFrame:GetUsingFrame()

		if frame == curFrame then
			cd:Done()
		elseif not table.exists(AppServices.AvatarFrame:GetUnlockFrames(), frame) then
			cd:Done()
		else
			AppServices.AvatarFrame:ModifyAvatarFrame(frame, function()
				cd:Done()
			end)
		end
	elseif name == ModifyHeadImagePanelNotificationEnum.Select_New_HeadImage then
		local oldAvatar = body.oldAvatar
		local newAvatar = body.newAvatar
		panel:OnSelectAvatar(oldAvatar, newAvatar)
	elseif name == ModifyHeadImagePanelNotificationEnum.Select_New_AvatarFrame then
		local oldFrame = body.oldFrame
		local newFrame = body.newFrame
		panel:OnSelectAvatarFrame(oldFrame, newFrame)
	end
end

-- function ModifyHeadImagePanelMediator:SelectNewHeadImage(newNum)
-- 	if newNum == CONST.GAME.HEADIMAGE_FACEBOOK_AVATAR_NUM and not App.loginLogic:IsFbAccount() then
-- 		self:Login()
-- 		return
-- 	end
-- 	if newNum == self.headImageNum then
-- 		return
-- 	end
-- 	panel:OnSelectAvatar(self.headImageNum,newNum)
-- 	self.headImageNum = newNum
-- 	--console.error("self.headImageNum", self.headImageNum)
-- end

function ModifyHeadImagePanelMediator:onBeforeLoadAssets()
	-- 在资源即在之前，用于进行服务器请求或额外的资源加载。
	-- Send Request To Server
	local extraAssetsNeedLoad = {}
	table.insert(extraAssetsNeedLoad, "Prefab/UI/UserInfo/ModifyHeadImage/headImageItem.prefab")
	table.insert(extraAssetsNeedLoad, "Prefab/UI/UserInfo/ModifyHeadImage/headImageItem_fb.prefab")
	table.insert(extraAssetsNeedLoad, "Prefab/UI/UserInfo/ModifyHeadImage/AvatarFrameItem.prefab")
	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
end

-- function ModifyHeadImagePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function ModifyHeadImagePanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	end

-- 	panel:InitHeadImages(self.headImageNum,selectNewHeadImage)
-- end
-- function ModifyHeadImagePanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function ModifyHeadImagePanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function ModifyHeadImagePanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function ModifyHeadImagePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function ModifyHeadImagePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function ModifyHeadImagePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function ModifyHeadImagePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function ModifyHeadImagePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

-- function ModifyHeadImagePanelMediator:Login()
-- 	DcDelegates:Log("fb_connect")
-- 	App.loginLogic:IngameLogin_start("fb",
-- 	function()
-- 		print("!!!!!!!!!!!!!!!! FACEBOOK CONNECT SUCCESS") --@DEL
-- 		if AppServices.User:HaveFbAccount() and App.loginLogic.PlayerInfo.fbBind then --首次绑定FB刷新头像
-- 			panel:OnSelectAvatar(self.headImageNum, CONST.GAME.HEADIMAGE_FACEBOOK_AVATAR_NUM)
-- 			self.headImageNum = CONST.GAME.HEADIMAGE_FACEBOOK_AVATAR_NUM
-- 		end

-- 		panel:OnLogin(self.headImageNum)
-- 	end
-- 	)
-- end

return ModifyHeadImagePanelMediator