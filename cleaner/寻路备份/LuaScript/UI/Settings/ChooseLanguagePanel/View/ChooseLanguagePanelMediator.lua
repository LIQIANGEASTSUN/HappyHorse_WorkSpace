require "UI.Settings.ChooseLanguagePanel.ChooseLanguagePanelNotificationEnum"
local ChooseLanguagePanelProxy = require "UI.Settings.ChooseLanguagePanel.Model.ChooseLanguagePanelProxy"

local ChooseLanguagePanelMediator = MVCClass('ChooseLanguagePanelMediator', BaseMediator)

local panel
local proxy

function ChooseLanguagePanelMediator:ctor(...)
	ChooseLanguagePanelMediator.super.ctor(self,...)
	proxy = ChooseLanguagePanelProxy.new()
end

function ChooseLanguagePanelMediator:onRegister()
end

function ChooseLanguagePanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function ChooseLanguagePanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
		ChooseLanguagePanelNotificationEnum.Click_btn,
		ChooseLanguagePanelNotificationEnum.Click_btn_close
	}
end

function ChooseLanguagePanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType()
	local body = notification:getBody() --message data
	--insertHandleNotificationNames
	if(name == "") then
	elseif(name == ChooseLanguagePanelNotificationEnum.Click_btn_close) then
		PanelManager.closeTopPanel()
	elseif name == ChooseLanguagePanelNotificationEnum.Click_btn then
		self:SaveForLang(body)
	else
	end
end

-- local filename = "lang.dat"
function ChooseLanguagePanelMediator:SaveForLang(lang)
    -- local filepath = FileUtil.GetPersistentPath() .. "/" .. filename
	-- local current = FileUtil.ReadFromFile(filepath)
	local current = AppServices.User:GetLanguage()
    if current ~= lang then
		-- FileUtil.SaveWriteFile(lang, filepath)
		AppServices.User:SetLanguage(lang)
		--CS.UnityEngine.PlayerPrefs.Save()
		--console.error(AppServices.User.GetLanguage(), LogicContext:GetDefaultLanguage())
		DcDelegates:Log(SDK_EVENT.user_language, {osLanguage = LogicContext:GetDefaultLanguage(), language = AppServices.User:GetLanguage(), type = 2})
		--ErrorHandler.ShowErrorMessage(Runtime.Translate("language.quit.game.alert.text"), function() ReenterGame(true) end)
		Localization.Instance:Reload()
		Localization.Instance:ReloadWithLang()
		Localization.Instance:LoadFile("Dialog")
		Localization.Instance:LoadFile('Guide')
		Localization.Instance:LoadFile('Pops')
		Localization.Instance:LoadFile('SystemErrorCode')
		Localization.Instance:LoadFile('Tips')
		Localization.Instance:LoadFile('UI')
		Localization.Instance:LoadFile("Story")
		Localization.Instance:LoadFile("AI")
		Localization.Instance:LoadFile("Obstacle")
		Localization.Instance:LoadFile("Dragon")
		Localization.Instance:OnLanguageChanged()
		AppServices.User:InitLanguage()

		App.scene:Trigger("OnLanguageChanged")
    end
	panel:OnSelectLanguage(lang)
end

-- function ChooseLanguagePanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function ChooseLanguagePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

 function ChooseLanguagePanelMediator:onBeforeShowPanel()
	--在第一次显示之前，此时visible=false。
	panel:refreshUI()
 end
-- function ChooseLanguagePanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function ChooseLanguagePanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function ChooseLanguagePanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function ChooseLanguagePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function ChooseLanguagePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function ChooseLanguagePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function ChooseLanguagePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function ChooseLanguagePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return ChooseLanguagePanelMediator
