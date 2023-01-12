---@class ConnectingTimeConfig
local ConnectingTimeConfig = {
    ---静默连接时长, 静默结束后出现转圈圈
    SilentTime = 2,
    ---转圈等待时长, 超时后出现转圈, 为了让能很快返回的消息避免重复转圈圈
    RollingWait = 2,
    ---转圈时长, 超时后出现Mask
    Rolling = 2,
}

---@class ConnectingPanelLogic
local ConnectingPanelLogic = {
    connectingTime = 0, --@DEL
    curMessageId = nil
}
---转圈的时间
local _rollingTime = 2

function ConnectingPanelLogic:Initialize()
    local go = BResource.InstantiateFromAssetName(CONST.ASSETS.G_CONNECTING_PANEL)
    self.go = go
    GameObject.DontDestroyOnLoad(self.go)
    self.mask = self.go:FindGameObject("ConnectingPanel/Mask")
    self.restartBoard = find_component(go, "ConnectingPanel/restartBoard")
    self.label_title = find_component(go, "ConnectingPanel/restartBoard/label_title", Text)
    self.label_tip = find_component(go, "ConnectingPanel/restartBoard/label_tip", Text)
    self.label_btn = find_component(go, "ConnectingPanel/restartBoard/Button/Text", Text)
    self.btn = find_component(go, "ConnectingPanel/restartBoard/Button", Button)
    self.spine = self.go:FindGameObject("ConnectingPanel/Spine")
    self.spineBg = find_component(go, "ConnectingPanel/SpineBg", Image)
    self.spine:SetActive(false)
    self.spineBg:SetActive(false)
    self.mask:SetActive(false)
    self.restartBoard:SetActive(false)
    self:_close()

    Util.UGUI_AddButtonListener(self.btn.gameObject, function()
        --检查停服状态
		AppServices.ShutDownServerLogic:Check()
        self:Log(4)
        self._showConnectingTime = nil
        self.restartBoard:SetActive(false)
        Runtime.InvokeCbk(self.clickCall)
    end)
end

function ConnectingPanelLogic:Log(subKey)
    DcDelegates:LogWithProbability(SDK_EVENT.weak_network_10, {subKey = subKey, protoId = self.curMessageId}, 10)
end

function ConnectingPanelLogic:ShowPanel(showloading)
    if Runtime.CSNull(self.go) then
        return
    end
    console.print("ConnectingPanelLogic --- ShowPanel", showloading) --@DEL
    if not showloading then
        --静默状态没有阻挡模式, 超过多久未响应的时候, 会自动展开阻挡
        if not self._silentTimer then
            self._silentTimer = WaitExtension.SetTimeout(function()
                self._silentTimer = nil
                self:ShowPanel(true)
            end, ConnectingTimeConfig.SilentTime)
        end
    else
        --非静默模式展开阻挡, 直接开始转圈圈?
        if self._silentTimer then
            WaitExtension.CancelTimeout(self._silentTimer)
            self._silentTimer = nil
        end
        if self._isShowing then
            return
        end
        self:_showPanel(true)
        if not self._rollingTimer then
            self._rollingTimer = WaitExtension.SetTimeout(function()
                self._rollingTimer = nil
                self:ShowConnecting()
            end, ConnectingTimeConfig.RollingWait)
        end
    end
end

---@private
---显示/隐藏带透明阻挡的主体
function ConnectingPanelLogic:_showPanel(isShow)
    self._isShowing = isShow
    self.go:SetActive(isShow)
end

---显示转圈圈
function ConnectingPanelLogic:ShowConnecting(showMaskNow)
    if Runtime.CSNull(self.go) then
        return
    end
    self.spine:SetActive(true)
    self.spineBg:SetActive(true)
    local function set(val)
        if Runtime.CSValid(self.spine) then
            self.spine.transform.localEulerAngles = Vector3(0, 0, val)
        end
    end
    -- console.print("ConnectingPanelLogic --- ShowConnecting") --@DEL
    local rollFunc = function()
        -- console.print("ConnectingPanelLogic --- Roll") --@DEL
        if Runtime.CSValid(self.spine) then
            local angle_z = self.spine.transform.localEulerAngles[2]
            DOTween.To(set, angle_z, angle_z - 360, _rollingTime)
        end
    end
    self:Log(1)
    self._showConnectingTime = TimeUtil.ServerTime()
    if not self.repeatId then
        self.repeatId = WaitExtension.InvokeRepeating(rollFunc, 0, _rollingTime)
        rollFunc()
    end
    if showMaskNow then
        if self.maskTimerId then
            WaitExtension.CancelTimeout(self.maskTimerId)
            self.maskTimerId = nil
        end
        self:ShowMask()
    else
        if not self.maskTimerId then
            self.maskTimerId = WaitExtension.SetTimeout(
                function()
                    self.maskTimerId = nil
                    self:ShowMask()
                end, ConnectingTimeConfig.Rolling)
        end
    end
end

---显示黑色遮罩
function ConnectingPanelLogic:ShowMask()
    if Runtime.CSNull(self.go) then
        return
    end
    console.print("ConnectingPanelLogic --- ShowMask") --@DEL
    self:Log(2)
    self.mask:SetActive(true)
    self.spineBg:SetActive(false)
end

---显示重连面板
function ConnectingPanelLogic:ShowRestartBoard(clickCall, errorCode)
    if Runtime.CSNull(self.go) then
        return
    end
    Runtime.Localize(self.label_title, "UI_no_network_tittle")
    local str = Runtime.Translate("UI_no_network_desc") .. string.format("(%s)", tostring(errorCode))
    --Runtime.Localize(self.label_tip, str)
    self.label_tip.text = str
    Runtime.Localize(self.label_btn, "UI_no_network_button")
    console.print("ConnectingPanelLogic --- ShowRestartBoard") --@DEL
    self:ShowConnecting(true)
    self.clickCall = clickCall
    local showConnectingTime = self._showConnectingTime
    if showConnectingTime and (TimeUtil.ServerTime() - showConnectingTime) > _rollingTime then
        if self._restartBoardTimer then
            WaitExtension.CancelTimeout(self._restartBoardTimer)
            self._restartBoardTimer = nil
        end
        self:Log(3)
        self.restartBoard:SetActive(true)
    else
        if not self._restartBoardTimer then
            self._restartBoardTimer = WaitExtension.SetTimeout(function()
                self._restartBoardTimer = nil
                self:Log(3)
                self.restartBoard:SetActive(true)
            end, _rollingTime)
        end
    end

end

function ConnectingPanelLogic:stopTimers()
    if self._rollingTimer then
        WaitExtension.CancelTimeout(self._rollingTimer)
        self._rollingTimer = nil
    end
    if self._silentTimer then
        WaitExtension.CancelTimeout(self._silentTimer)
        self._silentTimer = nil
    end
    if self.maskTimerId then
        WaitExtension.CancelTimeout(self.maskTimerId)
        self.maskTimerId = nil
    end
    if self.repeatId then
        WaitExtension.CancelTimeout(self.repeatId)
        self.repeatId = nil
    end
    if self._restartBoardTimer then
        WaitExtension.CancelTimeout(self._restartBoardTimer)
        self._restartBoardTimer = nil
    end
end

function ConnectingPanelLogic:_close()
    -- console.print("ConnectingPanelLogic --- _close") --@DEL
    self.mask:SetActive(false)
    self.spine:SetActive(false)
    self.spineBg:SetActive(false)
    self.restartBoard:SetActive(false)
    self:_showPanel(false)
    self:stopTimers()
end

function ConnectingPanelLogic:ClosePanel()
    self.connectingTime = TimeUtil.ServerTime() - self.connectingTime --@DEL
    self._showConnectingTime = nil
    self:_close()
end

---点击重连
function ConnectingPanelLogic:clickRestart()
    ConnectionManager:RestartGame()
    self:ClosePanel()
end

function ConnectingPanelLogic:SetMessageId(messageId)
    self.curMessageId = messageId
end

function ConnectingPanelLogic:DestroyPanel()
    self:stopTimers()
    Runtime.CSDestroy(self.go)
    self.go = nil
end

ConnectingPanelLogic:Initialize()

return ConnectingPanelLogic
