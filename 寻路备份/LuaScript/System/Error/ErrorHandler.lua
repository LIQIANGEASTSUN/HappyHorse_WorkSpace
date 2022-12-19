require "UI.Common.NoticePanel.NoticePanel"

---@class ErrorHandler
ErrorHandler = class(nil, "ErrorHandler")
ErrorHandler.message = nil

function ErrorHandler.ShowErrorPanel(errorCode, callback, hideButton)
    if errorCode == ErrorCodeEnums.NOT_PROCESSED or errorCode == ErrorCodeEnums.NOT_SENT then
        console.warn(nil, "ShowErrorPanel", errorCode)
        return Runtime.InvokeCbk(callback)
    end
    --App:OnErrorCode(errorCode)
    local message = ErrorHandler.GetErrorMessage(errorCode)
    if not message then
        return Runtime.InvokeCbk(callback)
    end
    ErrorHandler.ShowErrorMessage(message, callback, hideButton)
end

function ErrorHandler.GetErrorMessage(errorCode, withoutCode)
    if not errorCode then
        return
    end
    local key = "errorcode_" .. errorCode
    local message = Runtime.Translate(key)
    if message == key then
        message = Runtime.Translate("errorcode_default")
        withoutCode = false -- 没配文本时需要把错误码输出
    end
    if withoutCode then
        return message
    else
        return message .. "(" .. tostring(errorCode) .. ")"
    end
end

function ErrorHandler.ShowErrorMessage(message, callback, hideButton)
    console.warn(nil, "ShowErrorMessage" .. message)
    if not App.scene then return end
    if ErrorHandler.message == message then return end

    ErrorHandler.message = message

    local function OnPanelClosed()
        ErrorHandler.message = nil
        if type(callback) == "function" then
            callback()
        end
    end

    local ErrorMessagePanel = include("UI.Common.ErrorMessagePanel.ErrorMessagePanel")
    local panel = ErrorMessagePanel:Create()
    panel:SetText(message)
    panel:SetCloseCallback(OnPanelClosed)
    panel:HideButton(hideButton)
    panel:Show()
end

function ErrorHandler.ShowOkCancel(config)
    PanelManager.showPanel(GlobalPanelEnum.OkCancelPanel, config)
end

local lastNoticePanel
function ErrorHandler.ShowNotice(message, time, closeCallback)
    if lastNoticePanel then
        lastNoticePanel:Close()
        lastNoticePanel = nil
    end
    local noticePanel = NoticePanel:Create()
    noticePanel:SetText(message)
    noticePanel:Show(closeCallback, time)
    lastNoticePanel = noticePanel
end

-- 1.4.0
function ErrorHandler.ShowAssertMessage(message, callback, hideButton)
    if RuntimeContext.VERSION_DISTRIBUTE then
        console.error(message)
        Runtime.InvokeCbk(callback)
    else
        ErrorHandler.ShowErrorMessage(message, callback, hideButton)
    end
end