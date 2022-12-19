local BaseIconButton = require "UI.Components.BaseIconButton"

---@class ParkourButton:BaseIconButton
local ParkourButton = class(BaseIconButton)

function ParkourButton.Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_PARKOUR_BTN)
    local instance = ParkourButton.new()
    instance:InitWithGameObject(gameObject)
    App.scene.layout:RightLayoutAddChild(instance)
    App.scene:AddWidget(CONST.MAINUI.ICONS.ParkourButton, instance)
    return instance
end

function ParkourButton:InitWithGameObject(go)
    self.gameObject = go
    self.transform = go.transform
    self.rectTransform = self:GetRectTransform()
    self.txt_time = find_component(go, "cd/txt", Text)
    self.img_reddot = find_component(go, "reddot", Image)
    -- self.outline_time = find_component(self.txt_time.gameObject, "", CS.UnityEngine.UI.Outline)
    -- self.interactable = true
    local mgr = ActivityServices.Parkour
    self.rankEndTime = mgr:GetRankEndTime()
    self.endTime = mgr:GetData().endTime

    if TimeUtil.ServerTime() < self.rankEndTime then
        self:StartRankTimer()
    else
        self:ShowRankEndBtn()
    end

    self:ShowRedDot()
    self:RegisterListener()

    Util.UGUI_AddButtonListener(
        self.gameObject,
        function()
            self:OnClick()
        end
    )
    self:CheckGuide()
end

function ParkourButton:RegisterListener()
end

function ParkourButton:RemoveListener()
end

function ParkourButton:StartRankTimer()
    self:CancelTimer()
    self:RankTimer()
    self.timer = WaitExtension.InvokeRepeating(function()
        self:RankTimer()
    end, 0, 1)
end

function ParkourButton:RankTimer()
    local leftTime = self.rankEndTime - TimeUtil.ServerTime()

    if leftTime <= 0 then
        self:CancelTimer()
        if Runtime.CSValid(self.txt_time) then
            self.txt_time.text = TimeUtil.SecToOver48H(0)
        end
        return
    end

    if Runtime.CSValid(self.txt_time) then
        local ret, time1, time2 = TimeUtil.SecToDayHour(leftTime, 24)
        if ret then
            str = Runtime.Translate("ui_goldpass_activitytime", {day = tostring(time1), hour = tostring(time2)})
        else
            str = Runtime.formatStringColor(time1, "f14333")
        end
        self.txt_time.text = str
    end
end

function ParkourButton:ShowRankEndBtn()
    self.showReward = true
    self:CancelTimer()
    self:ShowRedDot()
    self:ShowRewardDesc()
end

function ParkourButton:ShowRewardDesc()
    if Runtime.CSValid(self.txt_time) then
        self.txt_time.text = Runtime.Translate("ui_dragonPve_button_receive")
    end
end

function ParkourButton:CancelTimer()
    if self.timer then
        WaitExtension.CancelTimeout(self.timer)
        self.timer = nil
    end
end

function ParkourButton:OnClick()
    if TimeUtil.ServerTime() < self.rankEndTime then
        self:ShowActivityPanel()
    else
        self:ShowRankRewardPanel()
    end
end

function ParkourButton:ShowActivityPanel()
    ActivityServices.Parkour:ShowPanel()
    DcDelegates:Log(SDK_EVENT.parkour_click)
end

function ParkourButton:ShowRankRewardPanel()
    ActivityServices.Parkour:ShowRankRewardPanel()
end

function ParkourButton:ShowRedDot()
    if Runtime.CSValid(self.img_reddot) then
        self.img_reddot:SetActive(TimeUtil.ServerTime() > self.rankEndTime)
    end
end

function ParkourButton:ShowExitAnim()
    self._isShow = false
end

function ParkourButton:ShowEnterAnim()
    self._isShow = true
    self:CheckGuide()
    if self.showReward then
        self:ShowRewardDesc()
    end
end

function ParkourButton:CheckGuide()
    local start = ActivityServices.Parkour:GetTime()
    if App.mapGuideManager:HasComplete(GuideIDs.GuideParkour, start) then
        return
    end
    self.checkId = WaitExtension.SetTimeout(function()
        if Runtime.CSNull(self.gameObject) or PanelManager.GetTopPanel() ~= nil or App:IsScreenPlayActive() then
            return
        end
        if not self._isShow then
            return
        end
        App.mapGuideManager:StartSeries(GuideConfigName.GuideCustomHand, {target = self.gameObject, flip = true, priority = 101,parent = self.gameObject})
    end, 1)
end

function ParkourButton:ShowHandForOnce()
    if Runtime.CSValid(self.gameObject) then
        App.mapGuideManager:StartSeries(GuideConfigName.GuideCustomHand, {target = self.gameObject, flip = true, priority = 101,parent = self.gameObject})
    end
end

function ParkourButton:Dispose()
    self:RemoveListener()
    self:CancelTimer()
    App.scene.layout:RightLayoutDelChild(self)
    App.scene:DelWidget(CONST.MAINUI.ICONS.ParkourButton)
    self.super.Dispose(self)
end

return ParkourButton
