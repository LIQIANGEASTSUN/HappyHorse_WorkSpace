--insertWidgetsBegin
--	btn_ok	text_message	btn_cancel
--insertWidgetsEnd

--insertRequire
local _OkCancelPanelBase = require "UI.Common.OkCancelPanel.View.UI.Base._OkCancelPanelBase"
---@class OkCancelPanel : _OkCancelPanelBase
local OkCancelPanel = class(_OkCancelPanelBase)

OkCancelPanel.btnColor =
{
    green = 1,
    yellow = 2,
}

function OkCancelPanel:ctor()
end

function OkCancelPanel:onAfterBindView()
    local args = self.arguments
    if args.hideCloseBtn then
        self.btn_close:SetActive(false)
    end
    self.img_ok_dic = {}
    self.img_ok_dic[OkCancelPanel.btnColor.green] = self.img_ok_green
    self.img_ok_dic[OkCancelPanel.btnColor.yellow] = self.img_ok_yellow
    self.label_ok_dic = {}
    self.label_ok_dic[OkCancelPanel.btnColor.green] = self.label_ok_green
    self.label_ok_dic[OkCancelPanel.btnColor.yellow] = self.label_ok_yellow
    self.okDelay = args.okDelay
    self.endTime = args.endTime
    self.endTimeStr = args.endTimeStr
    self.timeColor = args.timeColor
    if args.useShort then
        self.text_message:SetActive(false)
        self.text_message_short:SetActive(true)
        self.text_message_time:SetActive(true)
    else
        self.text_message:SetActive(true)
        self.text_message_short:SetActive(false)
        self.text_message_time:SetActive(false)
    end
end

function OkCancelPanel:onAfterShowPanel()
    -- 在界面fadein之前点击界面上的按钮 导致界面关闭 会造成卡住的问题
    self.canClick = true
end

function OkCancelPanel:refreshUI()
end

function OkCancelPanel:SetPanelText()
    local config = self.arguments
    if config.showOk then
        self:SetComponentVisible(self.btn_ok, true)
        if config.okColor == nil then
            config.okColor = OkCancelPanel.btnColor.green
        end
        for color, img in pairs(self.img_ok_dic) do
            img.gameObject:SetActive(color == config.okColor)
        end
        for color, label in pairs(self.label_ok_dic) do
            if color == config.okColor then
                label.text = config.label_ok or Runtime.Translate("ui_common_ok")
                label.gameObject:SetActive(true)
            else
                label.gameObject:SetActive(false)
            end
        end
    else
        self:SetComponentVisible(self.btn_ok, false)
    end
    if config.showCancel then
        self:SetComponentVisible(self.btn_cancel, true)
        self.label_cancel.text = config.label_cancel or Runtime.Translate("ui_common_cancel")
    else
        self:SetComponentVisible(self.btn_cancel, false)
    end

    if config.showOk and config.showCancel and config.switchButtonPos then
        self.btn_ok.transform:SetAsLastSibling()
    end

    local title = config.title or ''
    self.label_title.text = title
    self.text_message.text = config.desc or ''
    self.text_message_short.text = config.desc or ''
    self.title = title
    if self.okDelay then
        self.closeTime = self.okDelay + TimeUtil.ServerTime()
        self:StartOkDelay()
    end
    if self.endTime then
        self:StartTick()
    end
end

function OkCancelPanel:StartOkDelay()
    local function tick()
        local config = self.arguments
        for color, label in pairs(self.label_ok_dic) do
            if color == config.okColor then
                local txt = config.label_ok or Runtime.Translate("ui_common_ok")
                local now = TimeUtil.ServerTime()
                local cur = self.closeTime - now
                cur = math.max(0, cur)
                local newTxt = string.format("%s(%d)", txt, tostring(math.round(cur)))
                label.text = newTxt
                if cur <= 0 then
                    self:StopOkDelay()
                    sendNotification(OkCancelPanelNotificationEnum.Click_btn_ok)
                end
            end
        end
    end
    self._okDelayTimer = WaitExtension.InvokeRepeating(tick, 0, 1)
    Runtime.InvokeCbk(tick)
end

function OkCancelPanel:StopOkDelay()
    if self._okDelayTimer then
        WaitExtension.CancelTimeout(self._okDelayTimer)
        self._okDelayTimer = nil
    end
end

function OkCancelPanel:StartTick()
    if not self._tickTimer then
        self._tickTimer = WaitExtension.InvokeRepeating(function()
            self:OnTick()
        end, 0, 1)
        self:OnTick()
    end
end

function OkCancelPanel:OnTick()
    if self.endTime and Runtime.CSValid(self.text_message_time) then
        local leftTime = self.endTime - TimeUtil.ServerTime()
        if leftTime <= 0 then
            if Runtime.CSValid(self.text_message_time) then
                self.text_message_time.text = TimeUtil.SecToOver48H(0)
            end
            self:CancelTick()
            WaitExtension.InvokeDelay(function()
                PanelManager.closePanel(GlobalPanelEnum.OkCancelPanel)
            end)
            return
        end
        local ret, time1, time2 = TimeUtil.SecToDayHour(leftTime, 24)
        local str_time
        if ret then
            str_time = Runtime.Translate("ui_goldpass_activitytime", {day = tostring(time1), hour = tostring(time2)})
        else
            str_time = time1
        end
        local str = Runtime.formatStringColor(str_time, self.timeColor)
        -- self.text_message_time.text = Runtime.Translate(self.endTimeStr)..str
        self.text_message_time.text = Runtime.Translate(self.endTimeStr, {time=str})
    end
end

function OkCancelPanel:CancelTick()
    if self._tickTimer then
        WaitExtension.CancelTimeout(self._tickTimer)
        self._tickTimer = nil
    end
end

function OkCancelPanel:OnRelease()
    self:StopOkDelay()
    self:CancelTick()
end

return OkCancelPanel
