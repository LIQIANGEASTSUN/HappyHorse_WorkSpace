---@class PopupManager
PopupManager = {
    blocks = 0,
    block_dic = {},
    jobs = {},
    suspendJobs = {}
}

function PopupManager:CallWhenIdle(callback, checkFunc)
    if not App.popupQueue:IsFinished() then
        -- console.error("严格禁止在队列没有全部完成的情况下,调用CallWhenIdle") --@DEL
        console.datui("在队列没有全部完成的情况下,调用CallWhenIdle, job被挂起, 等队列结束后执行") --@DEL
        table.insert(self.suspendJobs, {callback = callback, checkFunc = checkFunc})
        return
    end
    table.insert(self.jobs, {callback = callback, trace = RuntimeContext.TRACE_BACK(), checkFunc = checkFunc})
    self:Start()
end

-------------自定义加锁/解锁-------------
function PopupManager:InsertBlock(key)
    self.blocks = self.blocks + 1
    if not self.block_dic[key] then
        self.block_dic[key] = 0
    end
    self.block_dic[key] = self.block_dic[key] + 1
end

function PopupManager:RemoveBlock(key)
    if not self.block_dic[key] then
        return
    end
    self.block_dic[key] = self.block_dic[key] - 1
    if self.block_dic[key] == 0 then
        self.block_dic[key] = nil
    end
    self.blocks = self.blocks - 1
end

function PopupManager:HasBlock()
    return self.blocks > 0
end
-----------------------------------------

function PopupManager:IsIdleMainCity(excludePanel)
    if self:HasBlock() then
        return false
    end

    if App.screenPlayActive then
        return false
    end

    if App.changingScene then
        return false
    end

    if App.scene:IsExploitCity() then
        return false
    end

    if App.scene:IsParkourCity() then
        return false
    end
    if App.scene:IsMowCity() then
        return false
    end

    --有引导
    if App.mapGuideManager:HasRunningGuide() then
        return false
    end

    --有协议未返回
    if ConnectionManager.transponder:GetSendState() then
        return false
    end
    -- if not App.popupQueue:IsFinished() then
    --     console.error("严格禁止在队列没有全部完成的情况下,调用CallWhenIdle") --@DEL
    --     return false
    -- end

    --有面板
    if PanelManager.isShowingAnyPanel() then
        if excludePanel and PanelManager.isPanelShowing(excludePanel) then
        else
            return false
        end
    end
    --引导是否挂起进程
    if App.mapGuideManager:IsSuspendJob() then
        return false
    end

    return true
end

function PopupManager:Start()
    if self.timerId then
        return
    end
    self.timerId =
        WaitExtension.InvokeRepeating(
        function()
            self:Update()
        end,
        0,
        0
    )
end

function PopupManager:Update()
    if self:IsIdleMainCity() then
        if self.popping then
            if self.popping.checkFunc and not self.popping.checkFunc() then
                console.datui("PopupManager:有job的checkFunc 返回false 本次跳过 下次继续检测") --@DEL
                return
            end
            local ret = Runtime.InvokeCbk(self.popping.callback)
            if not ret then
                console.error(self.popping.trace)
            end
            self.popping = nil
        else
            if #self.jobs == 0 then
                return self:Stop()
            end
            self.popping = table.remove(self.jobs, 1)
        end
    end
end

function PopupManager:Stop()
    if self.timerId then
        WaitExtension.CancelTimeout(self.timerId)
        self.timerId = nil
    end
    self.jobs = {}
    self.suspendJobs = {}
end

function PopupManager:OnPopupQueueFinished()
    for _, value in ipairs(self.suspendJobs) do
        table.insert(
            self.jobs,
            {
                callback = value.callback,
                checkFunc = value.checkFunc,
                trace = RuntimeContext.TRACE_BACK()
            }
        )
    end
    self.suspendJobs = {}
    self:Start()
end

function PopupManager:Init()
    if self.isInited then
        return
    end
    self.isInited = true
    MessageDispatcher:AddMessageListener(MessageType.PopupQueue_FINISHED, self.OnPopupQueueFinished, self)
end

PopupManager:Init()
if RuntimeContext.VERSION_DEVELOPMENT then
    function PopupManager:ReportStatus()
        local blocks = "blocks:["
        for k, _ in pairs(self.block_dic) do
            blocks = blocks .. k .. "/"
        end
        blocks = blocks .. "]"
        local desc =
            string.format(
            "Screenplay:%s RunningGuide:%s PopupQueue:%s ShowAnyPanel:%s SuspendJob:%s",
            App.screenPlayActive,
            App.mapGuideManager:HasRunningGuide(),
            App.popupQueue:WorkingJobName(),
            PanelManager.isShowingAnyPanel(),
            App.mapGuideManager:IsSuspendJob()
        )
        console.systrace("PopupManager:ReportStatus", blocks, desc)
    end

    App:AddAppOnPauseCallback(
        function()
            PopupManager:ReportStatus()
        end
    )
end
