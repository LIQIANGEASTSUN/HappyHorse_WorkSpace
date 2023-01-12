require "UI.Settings.GiftCodePanel.GiftCodePanelNotificationEnum"
local GiftCodePanelProxy = require "UI.Settings.GiftCodePanel.Model.GiftCodePanelProxy"

local GiftCodePanelMediator = MVCClass('GiftCodePanelMediator', BaseMediator)

---@type GiftCodePanel
local panel
local proxy

function GiftCodePanelMediator:ctor(...)
	GiftCodePanelMediator.super.ctor(self,...)
	proxy = GiftCodePanelProxy.new()
end

function GiftCodePanelMediator:onRegister()
end

function GiftCodePanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function GiftCodePanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
		GiftCodePanelNotificationEnum.Click_btn_close,
		GiftCodePanelNotificationEnum.Click_btn_confirm
	}
end

function GiftCodePanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
	if (name == GiftCodePanelNotificationEnum.Click_btn_close) then
		PanelManager.closePanel(GlobalPanelEnum.GiftCodePanel)
	elseif name == GiftCodePanelNotificationEnum.Click_btn_confirm then
		local str = panel.txt_code.text
		if string.isEmpty(str) then
			return
		end
		self:SendGfitCode(str,function ()
			if panel and Runtime.CSValid(panel.txt_code) then
				panel.txt_code.text = ""
			end
		end)
	end
end

function GiftCodePanelMediator:SendGfitCode(codeStr,onSuccallback)
	-- body
	local _, uid = AppServices.AccountData:GetLastLoginAccount()
    if not uid then
        uid = ""
    end
    local headers = {
        code = codeStr,
        pid = uid,
        version = RuntimeContext.BUNDLE_VERSION,
        os = CONST.RULES.GetOsType(),
    }

	if RuntimeContext.VERSION_DEVELOPMENT and headers.os == 2 then
		--如果是开发版本且是在pc上，统一使用安卓标签做测试
		headers.os = 0
	end
    local function onSuc(ret)
        local response = table.deserialize(ret, true)
        if response then
            if response.code == 0 then
                local strs = string.split(response.goods, ",") or {}
                local rwd = {}
                if #strs > 0 then
                    for _, str in ipairs(strs) do
                        local item = string.split(str, "_") or {}
                        if #item == 2 then
                            table.insert(rwd, {ItemId = item[1], Amount = item[2]})
							AppServices.User:AddItem(item[1],item[2],ItemGetMethod.GiftCode)
                        end
                    end
                end
                PanelManager.showPanel(GlobalPanelEnum.CommonRewardPanel,{rewards = rwd})
				Runtime.InvokeCbk(onSuccallback)
            else
                --ErrorHandler.ShowErrorMessage(Runtime.Translate("UI_CDKEY_errorcode_"..response.code))
				UITool.ShowContentTipAni(Runtime.Translate("UI_CDKEY_errorcode_"..response.code))
            end
        end
		Util.BlockAll(0, "GiftCode")
    end
    local function onFail(msg)
		Util.BlockAll(0, "GiftCode")
        ErrorHandler.ShowErrorPanel(msg)
    end
    local body = table.serialize(headers)
    App.httpClient:SendWebHttpRequest(NetworkConfig.cdKeyUrl,body,onSuc,onFail)
	Util.BlockAll(30, "GiftCode")
end

-- function GiftCodePanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function GiftCodePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function GiftCodePanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function GiftCodePanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function GiftCodePanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function GiftCodePanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function GiftCodePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function GiftCodePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function GiftCodePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function GiftCodePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function GiftCodePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return GiftCodePanelMediator
