require "UI.Mail.MailMainPanel.MailMainPanelNotificationEnum"
local MailMainPanelProxy = require "UI.Mail.MailMainPanel.Model.MailMainPanelProxy"

local MailMainPanelMediator = MVCClass("MailMainPanelMediator", BaseMediator)

---@type MailMainPanel
local panel
local proxy

function MailMainPanelMediator:ctor(...)
    MailMainPanelMediator.super.ctor(self, ...)
    proxy = MailMainPanelProxy.new()
end

function MailMainPanelMediator:onRegister()
end

function MailMainPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function MailMainPanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        MailMainPanelNotificationEnum.Click_btn_remove_all,
        MailMainPanelNotificationEnum.Click_btn_fetch_all,
        MailMainPanelNotificationEnum.Click_btn_close,
        MailMainPanelNotificationEnum.RefillSingleMail,
        MailMainPanelNotificationEnum.ResetMailList,
        MailMainPanelNotificationEnum.RemoveSingleMail,
        MailMainPanelNotificationEnum.RefillMailList
    }
end

function MailMainPanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType()
    local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == "") then
    elseif (name == MailMainPanelNotificationEnum.Click_btn_remove_all) then
        ErrorHandler.ShowOkCancel(
            {
                showOk = true,
                showCancel = true,
                desc = Runtime.Translate("ui_mail_remove_all_message"),
                okCallback = function()
                    AppServices.MailManager:RemoveAllReadMail()
                end
            }
        )
    elseif (name == MailMainPanelNotificationEnum.Click_btn_fetch_all) then
        AppServices.MailManager:FetchAllMailAttachments(
            nil,
            function(flag, rewards)
                if flag == true or flag == nil then
                    panel:RefillMainList()
					panel:FlyRewards(rewards)
                else
                    ErrorHandler.ShowOkCancel(
                        {
                            showOk = true,
                            desc = Runtime.Translate("ui_mail_fetch_no_message")
                        }
                    )
                end
            end
        )
    elseif name == MailMainPanelNotificationEnum.Click_btn_close then
        PanelManager.closePanel(GlobalPanelEnum.MailMainPanel)
    elseif name == MailMainPanelNotificationEnum.ResetMailList then
        panel:FillMainList()
    elseif name == MailMainPanelNotificationEnum.RefillMailList then
        panel:RefillMainList()
    elseif name == MailMainPanelNotificationEnum.RefillSingleMail then
        for i, v in pairs(body) do
            panel:RefillSingleMail(v)
        end
    elseif name == MailMainPanelNotificationEnum.RemoveSingleMail then
        panel:RemoveSingleMail(body)
    -- else
    end
end

-- function MailMainPanelMediator:onBeforeLoadAssets()
--  -- ??????????????????????????????????????????????????????????????????????????????
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function MailMainPanelMediator:onLoadAssetsFinish()
-- 	--????????????????????????BindView?????????
-- end

function MailMainPanelMediator:onBeforeShowPanel()
    --?????????????????????????????????visible=false???
    panel:refreshUI()
end
-- function MailMainPanelMediator:onAfterShowPanel()
-- 	--?????????????????????????????????visible=true???
-- end

-- function MailMainPanelMediator:onBeforeHidePanel()
-- 	--??????????????????(FadeOut?????????)?????????visible=true???
-- end
-- function MailMainPanelMediator:onAfterHidePanel()
-- 	--??????????????????(FadeOut?????????)?????????visible=false???
-- end

-- function MailMainPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--????????????????????????(FadeIn?????????)?????????visible=false???
-- 	panel:refreshUI()
-- end
-- function MailMainPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--????????????????????????(FadeIn?????????)?????????visible=true???
-- end

function MailMainPanelMediator:onBeforeDestroyPanel()
    --???????????????????????????visible=false???
    AppServices.MailManager:ExecuteDeleteData()
end

-- function MailMainPanelMediator:onBeforePausePanel()
-- 	--??????Popup???????????????????????????visible=true???
-- end
-- function MailMainPanelMediator:onAfterResumePanel()
-- 	--???Popup???????????????????????????visible=true???
-- 	panel:refreshUI()
-- end

return MailMainPanelMediator
