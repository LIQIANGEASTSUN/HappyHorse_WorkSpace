---
--- Created by Betta.
--- DateTime: 2022/5/13 14:19
---
local HomeSceneTopIconBase = require "UI.Components.HomeSceneTopIconBase"

---@class PiggyBankButton:HomeSceneTopIconBase
local PiggyBankButton = class(HomeSceneTopIconBase)

function PiggyBankButton.Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_PIGGYBANK_BTN)
    local instance = PiggyBankButton.new()
    instance:InitWithGameObject(gameObject)
    instance:ShowInfo(true)
    MessageDispatcher:AddMessageListener(MessageType.PiggyBankRefresh, instance.OnRefresh, instance)
    App.scene.layout:RightLayoutAddChild(instance, "ui_piggyBank_icon", true)
    --App.scene:AddWidget(CONST.MAINUI.ICONS.PiggyBankButton, instance)
    return instance
end

function PiggyBankButton:InitWithGameObject(go)
    self.gameObject = go
    self.transform = go.transform
    self.rectTransform = self:GetRectTransform()

    self.text_cd = find_component(go, "bg/txt_cd", Text)
    self.glow = find_component(go, "glow")
    self.text_add = find_component(go, "text_add", Text)
    self.flyTarget = find_component(go, "flyTarget", Transform)
    self.effect = find_component(go, "effect (2)")
    --self.text_energy = find_component(go, "txt_energy", Text)

    self.bg = find_component(go, "bg", Transform)
    self.icon = find_component(go, "bg/icon")
    self.grayIcon = find_component(go, "bg/grayIcon")

    self.bar = find_component(go, "mask/bar")
    self.txt_done = find_component(self.bar, "bg/bg_done/Text", Text)
    self.txt_process = find_component(self.bar, "bg/bg_progress/Text", Text)
    self.img_barIcon = find_component(self.bar, "bg/icon_img", Image)
    self.rawImg_barIcon = find_component(self.bar, "bg/icon_rawImg", RawImage)
    self.bg_done = find_component(self.bar, "bg/bg_done", Image)
    self.bg_progress = find_component(self.bar, "bg/bg_progress", Image)
    self.img_barIcon.sprite = AppServices.ItemIcons:GetSprite(ItemId.ENERGY)

    self.curAnimNum = 0
    self.sumAnimNum = 0

    Util.UGUI_AddButtonListener(
    self.gameObject,
    function()
        if AppServices.PiggyBank:IsOpen() then
            PanelManager.showPanel(GlobalPanelEnum.PiggyBankPanel)
        end
    end
    )
    self._popBarQueue = {}
    self._isShow = true
end

function PiggyBankButton:ShowInfo(isInit)
    self.cfg = AppServices.PiggyBank:GetCfg()
    self.endTime = AppServices.PiggyBank.starTime + self.cfg.eventTime * 60

    --[[if self.number then
        self:ShowValueWithAnimation(self.text_energy, self.number, AppServices.PiggyBank.energy)
    else
        self.text_energy.text = AppServices.PiggyBank.energy
    end--]]
    self.effect:SetActive(AppServices.PiggyBank:IsOpen())
    if AppServices.PiggyBank:IsOpen() then
        self.icon:SetActive(true)
        self.grayIcon:SetActive(false)
        if not isInit and self.number and self.number < AppServices.PiggyBank.energy then
            --self:DoTextAnim(AppServices.PiggyBank.energy - self.number)
            self:pushPopBar(AppServices.PiggyBank.energy, self.cfg.energyNum, nil, 'item', 11)
        end
        self.number = AppServices.PiggyBank.energy
    else
        self.icon:SetActive(false)
        self.grayIcon:SetActive(true)
        self.number = 0
    end
    self.glow:SetActive(AppServices.PiggyBank:CanBuy())
    self:StartTimer()
end

function PiggyBankButton:OnRefresh()
    self:ShowInfo()
end

function PiggyBankButton:DoTextAnim(value)
    if value <= 0 then
        return
    end
    if self.textAddAnimId then
        WaitExtension.CancelTimeout(self.textAddAnimId)
        self.textAddAnimId = nil
    end
    self.sumAnimNum = self.sumAnimNum + value
    self.text_add:SetActive(true)
    local stepCount = 15
    local step = math.max(1, math.ceil((self.sumAnimNum - self.curAnimNum) / stepCount))
    self.textAddAnimId = WaitExtension.InvokeRepeating(function()
        self.curAnimNum = math.min(self.sumAnimNum,  self.curAnimNum + step)
        self.text_add.text = "+" .. self.curAnimNum
        if self.curAnimNum == self.sumAnimNum then
            WaitExtension.CancelTimeout(self.textAddAnimId)
            self.textAddAnimId = nil
            self.curAnimNum = 0
            self.sumAnimNum = 0
            self:DoFlyAnim()
            self.text_add:SetActive(false)
        end
    end, 0, 0.1)
end

function PiggyBankButton:DoFlyAnim()
    local flyGo = GameObject.Instantiate(self.text_add.gameObject, self.transform, true)
    local transform = flyGo.transform
    --transform.position = self.text_add.transform.position
    --transform:SetParent()
    transform:DOMove(self.flyTarget.position, 1)
    transform:DOScale(0.2, 1)
    WaitExtension.SetTimeout(function()
        if Runtime.CSValid(flyGo) then
            GameObject.Destroy(flyGo)
            flyGo = nil
        end
        if Runtime.CSValid(self.bg) then
            local sequence = DOTween.Sequence()
            sequence:Append(self.bg:DOScale(1.1, 0.5))
            sequence:Append(self.bg:DOScale(1, 0.5))
        end
    end, 1)
end

function PiggyBankButton:OnTaskProgress(taskId, tlpId)
    local gpMgr = ActivityServices.GoldPass
    local taskCfg = gpMgr.GetTaskCfg(tlpId)
    local taskEntity = gpMgr:GetTaskEntity(taskId)
    local total = taskEntity:GetTotal()
    local cur = taskEntity:GetProgress()
    cur = math.min(cur, total)
    self:pushPopBar(cur, total, taskCfg.icon, taskCfg.icon_way, taskId)
end

function PiggyBankButton:pushPopBar(cur, total, icon, icon_way, taskId)
    local popInfo = {
        cur = cur,
        total = total,
        icon = icon,
        icon_way = icon_way,
        taskId = taskId
    }
    table.insert(self._popBarQueue, popInfo)
    if Runtime.CSValid(self.gameObject) then
        self:checkPopBar()
    end
end

function PiggyBankButton:checkPopBar()
    if not self._isShow or self._isBatchPop then
        if #self._popBarQueue > 1 then
            self:mergeSamePop()
        end
        return
    end
    if self._isPoping then
        if #self._popBarQueue > 1 then
            self:mergeSamePop()
        end
        return
    end
    local popInfo = table.remove(self._popBarQueue, 1)
    if not popInfo then
        return
    end
    self:PopBar(popInfo)
end

---合并相同的
function PiggyBankButton:mergeSamePop()
    local tmp = {}
    for _, popInfo in ipairs(self._popBarQueue) do
        local info = tmp[popInfo.taskId]
        if not info then
            info = popInfo
            tmp[popInfo.taskId] = info
        else
            if info.cur < popInfo.cur then
                tmp[popInfo.taskId] = popInfo
            end
        end
    end
    self._popBarQueue = {}
    for _, v in pairs(tmp) do
        table.insert(self._popBarQueue, v)
    end
end

function PiggyBankButton:PopBar(popInfo)
    local icon_way = popInfo.icon_way
    if Runtime.CSValid(self.bar) then
        self.bar:SetActive(true)
    end
    self.rawImg_barIcon:SetActive(icon_way == 'task')
    self.img_barIcon:SetActive(icon_way == 'item')
    --[[local viewCom
    if icon_way == 'task' then
        viewCom = self.rawImg_barIcon
    elseif icon_way == 'item' then
        viewCom = self.img_barIcon
    end--]]
    -- console.lzl('-----popbar', popInfo.taskId, popInfo.cur)
    local str = Runtime.formartCount(popInfo.cur, popInfo.total)
    local isDone = popInfo.cur >= popInfo.total
    self.bg_done.gameObject:SetActive(isDone)
    self.bg_progress.gameObject:SetActive(not isDone)

    self.txt_done:SetActive(isDone)
    self.txt_process:SetActive(not isDone)
    local txtCom = isDone and self.txt_done or self.txt_process
    txtCom.text = str

    self._isPoping = true
    GameUtil.DoAnchorPosX(
    self.bar.transform,
    -216,
    0.3,
    function()
        self:HideBar()
    end
    )
end

function PiggyBankButton:HideBar()
    if not Runtime.CSValid(self.bar) then
        return
    end
    self.delayHideId =
    WaitExtension.SetTimeout(function()
        if self.delayHideId then
            WaitExtension.CancelTimeout(self.delayHideId)
            self.delayHideId = nil
        end
        GameUtil.DoAnchorPosX(self.bar.transform, 0, 0.2, function()
            self._isPoping = nil
            if Runtime.CSValid(self.bar) then
                self.bar:SetActive(false)
            end
            if Runtime.CSValid(self.gameObject) then
                self:checkPopBar()
            end
        end)
    end, 0.5)
end


function PiggyBankButton:ShowExitAnim()
    self._isShow = false
    if Runtime.CSValid(self.bar) then
        self.bar:SetActive(false)
    end
    -- console.lzl('GoldPassButton:ShowExitAnim')
end

function PiggyBankButton:ShowEnterAnim()
    -- console.lzl('GoldPassButton:ShowEnterAnim')
    self._isShow = true
    if not self.isFinished then
        self:UpdateRedDot()
        self:checkPopBar()
    else
        self:ShowRewardDesc()
    end
end

function PiggyBankButton:StartTimer()
    if self.timer then
        WaitExtension.CancelTimeout(self.timer)
        self.timer = nil
    end
    self:Timer()
    self.timer =
    WaitExtension.InvokeRepeating(
    function()
        self:Timer()
    end,
    0,
    1
    )
end

function PiggyBankButton:Timer()
    local leftTime = self.endTime - TimeUtil.ServerTime()
    if leftTime <= 0 then
        if self.timer then
            WaitExtension.CancelTimeout(self.timer)
            self.timer = nil
        end
        MessageDispatcher:SendMessage(MessageType.PiggyBankRefresh)
        return
    end
    local ret, time1, time2 = TimeUtil.SecToDayHour(leftTime, 24)

    local str
    if ret then
        str = Runtime.Translate("ui_piggybank_desc_1", {day = tostring(time1), hour = tostring(time2)})
    else
        str = time1 --Runtime.formatStringColor(time1, "f14333")
    end
    self.text_cd.text = str
end

function PiggyBankButton:Dispose()
    self.gameObject:SetActive(false)
    --self:RemoveListener()
    MessageDispatcher:RemoveMessageListener(MessageType.PiggyBankRefresh, self.OnRefresh, self)
    if self.timer then
        WaitExtension.CancelTimeout(self.timer)
        self.timer = nil
    end
    if self.textAddAnimId then
        WaitExtension.CancelTimeout(self.textAddAnimId)
        self.textAddAnimId = nil
    end
    App.scene.layout:RightLayoutDelChild(self)
    self.super.Dispose(self)
end

return PiggyBankButton
