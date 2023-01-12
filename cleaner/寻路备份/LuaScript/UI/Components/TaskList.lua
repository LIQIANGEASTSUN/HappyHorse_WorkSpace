local BaseIconButton = require "UI.Components.BaseIconButton"

---@class TaskList:BaseIconButton
local TaskList = class(BaseIconButton, "TaskList")
---@return TaskList
function TaskList:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_TASKLIST)
    return TaskList:CreateWithGameObject(gameObject)
end

function TaskList:CreateWithGameObject(gameObject)
    local instance = TaskList.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function TaskList:InitWithGameObject(go)
    self.gameObject = go
    self.transform = go.transform
    self.rectTransform = self:GetRectTransform()
    local root = find_component(go, "root")
    self.list_container = find_component(root, "go_list", ScrollListRenderer)
    self.list_srt = find_component(root, "go_list", ScrollRect)
    self.go_taskProgress = find_component(root, "go_taskProgress")
    self.txt_taskPorgress = find_component(self.go_taskProgress, "Text", Text)
    self.arrow = find_component(go, "arrow")
    self.arrow:SetActive(false)
    Util.UGUI_AddEventListener(
        self.list_container.gameObject,
        UIEventName.onBeginDrag,
        function()
            self:SetLastFocusIndex()
            if self._showingKey then
                -- console.lzl('TaskList_LOG ----------------滑动了任务列表导致关闭了详情界面----------------') --@DEL
                self:HideTaskDetailInfo()
            end
        end,
        false
    )
    self.originalAnchoredPosY = self.rectTransform.anchoredPosition.y
    self.originalAnchoredPosX = self.rectTransform.anchoredPosition.x
    self.interactable = true
    self._updateQueue = {}
    self._startTasks = {}
    ---@type TaskSlot[]
    self.taskItemList = {}
    self.isEnter = true
    local unlock = AppServices.Unlock:IsUnlock("TaskIcon")
    if not unlock then
        MessageDispatcher:AddMessageListener(MessageType.Global_OnUnlock, self.UnlockButton, self)
        self.gameObject:SetActive(false)
        return
    end
    self:StartTick()
    self:RegisterKeyListener()
    MessageDispatcher:AddMessageListener(MessageType.PopupQueue_FINISHED, self.CheckListArrow, self)
    MessageDispatcher:AddMessageListener(MessageType.Task_ActivityTaskConfig_Loaded, self.CheckActivityTaskOver, self)
    App.scene:Register(
        self,
        "OnLanguageChanged",
        function()
            self:OnLanguageChanged()
        end
    )
end

function TaskList:UnlockButton(key)
    if key == "TaskIcon" then
        MessageDispatcher:RemoveMessageListener(MessageType.Global_OnUnlock, self.UnlockButton, self)
        self:InitList()
        self:ReleaseBlock()
        self.gameObject:SetActive(true)
        self:StartTick()
        self:RegisterKeyListener()
    end
end

function TaskList:SetTaskKind(taskKind)
    self.taskKind = taskKind
    self:InitList()
end

function TaskList:GetTaskIdList()
    local taskEntitiesList = AppServices.Task:GetCurOpenTasks(nil, self.taskKind)
    local taskIdList = {}
    for _, taskEntity in ipairs(taskEntitiesList) do
        table.insert(taskIdList, taskEntity.taskId)
    end
    return taskIdList
end

function TaskList:SwitchShowStoryProgress(isShow)
    if self._isShowStoryProgress == isShow then
        return
    end
    self._isShowStoryProgress = isShow
    self.go_taskProgress:SetActive(not (not isShow))
end

function TaskList:IsShowStoryProgress()
    return self._isShowStoryProgress
end

function TaskList:UpdateStoryProgress(taskId)
    local cur, total = AppServices.Task:GetActivitySceneTaskProgress(App.scene:GetCurrentSceneId())
    if not cur then
        self:SwitchShowStoryProgress(false)
        return
    end
    if cur < total then
        Runtime.Localize(
            self.txt_taskPorgress,
            "ui_storyprogress_title",
            {current = tostring(cur), total = tostring(total)}
        )
    else
        if taskId then
            AppServices.Task:PopupLastActivityTaskPanel(taskId)
        end
        Runtime.Localize(self.txt_taskPorgress, "ui_storyprogress_end")
    end
end

function TaskList:OnLanguageChanged()
    if Runtime.CSValid(self.txt_taskPorgress) then
        self:UpdateStoryProgress()
    end
end

function TaskList:CheckActivityTaskOver(sceneId)
    if sceneId ~= App.scene:GetCurrentSceneId() then
        return
    end
    local showStoryProgress = false
    if self.taskKind ~= TaskKind.Task then
        local cur = AppServices.Task:GetActivitySceneTaskProgress(App.scene:GetCurrentSceneId())
        if cur then
            showStoryProgress = true
        end
        self:SwitchShowStoryProgress(showStoryProgress)
        if showStoryProgress then
            self:UpdateStoryProgress()
        end
    end
end

function TaskList:InitList(taskIdList)
    taskIdList = taskIdList or self:GetTaskIdList()
    console.lzl('Task_LOG-----------InitList', self.taskKind, taskIdList and table.serialize(taskIdList))--@DEL
    local taskIdx2taskId = {}
    local taskIdxList = {}
    for i, taskId in ipairs(taskIdList) do
        table.insert(taskIdxList, i)
        taskIdx2taskId[i] = taskId
    end

    local showStoryProgress = false
    if self.taskKind ~= TaskKind.Task then
        local cur = AppServices.Task:GetActivitySceneTaskProgress(App.scene:GetCurrentSceneId())
        if cur then
            showStoryProgress = true
        end
    end
    self:SwitchShowStoryProgress(showStoryProgress)
    if showStoryProgress then
        self:UpdateStoryProgress()
    end
    local newTasks = nil
    if not table.isEmpty(self._startTasks) then
        newTasks = table.clone(self._startTasks, true)
        self._startTasks = {}
    end
    -- 获取选中
    local function getNewTargetIndex()
        local lastFocus = self:GetLastFocusIndex()
        if lastFocus then
            return lastFocus
        end
        local selectedTaskId = nil
        -- 参数传入的选中
        if self.showSelTask then
            selectedTaskId = self.showSelTask
            self.showSelTask = nil
        end
        if selectedTaskId then
            for idx, taskId in pairs(taskIdx2taskId) do
                if taskId == selectedTaskId then
                    return idx
                end
            end
        end
        return 1
    end
    local TaskSlot = require("UI.Task.View.UI.TaskSlot")
    local function onCreateItemCallback(key)
        -- console.lzl('TaskList_LOG___onCreateItemCallback', key) --@DEL
        local item = TaskSlot.Create(self, key)
        self.taskItemList[key] = item
        return item.gameObject
    end

    local function onUpdateInfoCallback(key, index)
        -- console.lzl('TaskList_LOG___onUpdateInfoCallback', key, index) --@DEL
        local taskId = taskIdx2taskId[index]
        local isNew = index <= 4 and newTasks and newTasks[taskId]
        if isNew then
            newTasks[taskId] = nil
        end
        self.taskItemList[key]:SetData(taskId, index, isNew)
    end

    local function removeCallback(index)
        -- console.lzl('TaskList_LOG___removeCallback  列表删除C#回调', index) --@DEL
        table.removev(self.indexList, index)
        self.index2TaskId[index] = nil
    end

    local newIndex = getNewTargetIndex()
    -- console.lzl('TaskList_LOG 更新列表的索引', newIndex) --@DEL
    for _, item in pairs(self.taskItemList) do
        item:destroy()
    end
    self.taskItemList = {}
    ---任务的索引对应任务id
    self.index2TaskId = taskIdx2taskId
    ---任务的索引数组
    self.indexList = taskIdxList
    local oldPos = self.list_container.rectTransformContainer.anchoredPosition
    self.list_container:InitList(#taskIdxList, onCreateItemCallback, onUpdateInfoCallback, removeCallback, newIndex, 0)
    self.list_container.rectTransformContainer.anchoredPosition = oldPos
end

function TaskList:ResetList(taskIdList)
    taskIdList = taskIdList or self:GetTaskIdList()
    local taskIdx2taskId = {}
    local taskIdxList = {}
    for i, taskId in ipairs(taskIdList) do
        table.insert(taskIdxList, i)
        taskIdx2taskId[i] = taskId
    end
    self.index2TaskId = taskIdx2taskId
    ---任务的索引数组
    self.indexList = taskIdxList
    local oldPos = self.list_container.rectTransformContainer.anchoredPosition
    self.list_container:ResetList(#taskIdxList, oldPos)
end

function TaskList:ShowTaskDetailInfo(taskId, index, key)
    self:HideTaskDetailInfo()
    if not self._taskDetailInfo then
        local TaskDetailInfo = require("UI.Task.View.UI.TaskDetailInfo")
        self._taskDetailInfo = TaskDetailInfo.Create(self)
    end
    local parentItem = self.taskItemList[key]
    self._showingKey = key
    -- console.lzl('----ShowTaskDetailInfo---', taskId, index, key)--@DEL
    self._taskDetailInfo:SetData(taskId, index, parentItem.gameObject)
end

function TaskList:HideTaskDetailInfo()
    -- console.lzl('----HideTaskDetailInfo---')--@DEL
    if self._showingKey then
        local item = self.taskItemList[self._showingKey]
        if item then
            item:HideSelect()
        end
        self._showingKey = nil
    end
    if self._taskDetailInfo then
        self._taskDetailInfo:setActive(false)
    end
end

function TaskList:OnTaskStart(taskKind, taskId)
    if taskKind ~= self.taskKind then
        return
    end
    self:pushUpdateQueue(taskId, TaskListRefreshKind.Start)
end

function TaskList:OnSubTaskFinish(taskKind, taskId)
    if taskKind ~= self.taskKind then
        return
    end
    self:pushUpdateQueue(taskId, TaskListRefreshKind.SubFinish)
end

function TaskList:OnTaskFinish(taskId, _, taskKind)
    if taskKind ~= self.taskKind then
        return
    end
    self:pushUpdateQueue(taskId, TaskListRefreshKind.Finish)
end

function TaskList:OnTaskSubmit(taskId, taskKind)
    if taskKind ~= self.taskKind then
        return
    end
    self:pushUpdateQueue(taskId, TaskListRefreshKind.Submit)
end

function TaskList:OnSubTaskAddProgress(taskKind, taskId, subIndex)
    if taskKind ~= self.taskKind then
        return
    end
    if not self._showingKey then
        return
    end
    local taskDetailInfo = self._taskDetailInfo
    if not taskDetailInfo then
        return
    end
    if taskDetailInfo.taskId ~= taskId then
        return
    end
    taskDetailInfo:UpdateTaskProgress(taskId, subIndex)
end
---@class TaskQueueState
local TaskQueueState = {
    Prepare = 0,
    Running = 1,
    Finish = 2
}

local TaskQueueStateName = table.reverse(TaskQueueState)
function TaskList:pushUpdateQueue(taskId, refreskKind)
    if not AppServices.Unlock:IsUnlock("TaskIcon") then
        return
    end
    -- console.lzl('TaskList_LOG pushUpdateQueue', AppServices.Task:GetTaskName(taskId), TaskListRefreshKindName[refreskKind], '是否立即执行', self.isEnter) --@DEL
    local node = {taskId = taskId, refreskKind = refreskKind, state = TaskQueueState.Prepare}
    -- table.insert(self._updateQueue, )
    local ok = self:AddQueueNode(node)
    -- console.lzl("TaskList_LOG 插入队列结果", ok) --@DEL
    -- console.lzl("TaskList_LOG 当前队列", ok, self:debugPrintQueue()) --@DEL
    if ok and self.isEnter then
        self:RunQueue()
    end
end

function TaskList:debugPrintQueue()
    local strs = {}
    for _, v in ipairs(self._updateQueue) do
        local t = {
            AppServices.Task:GetTaskName(v.taskId),
            TaskListRefreshKindName[v.refreskKind],
            TaskQueueStateName[v.state]
        }
        local tt = table.concat(t, "|")
        table.insert(strs, tt)
    end
    return table.concat(strs, "###")
end

function TaskList:AddQueueNode(newNode)
    local len = #self._updateQueue
    if len == 0 then
        table.insert(self._updateQueue, newNode)
        return true
    end

    if newNode.refreskKind == TaskListRefreshKind.Start then
        for ii = 1, len do
            local n = self._updateQueue[ii]
            if n.refreskKind == TaskListRefreshKind.Start then
                table.insert(self._updateQueue, ii + 1, newNode)
                return true
            end
        end
        table.insert(self._updateQueue, newNode)
        return true
    end
    for i = len, 1, -1 do
        local node = self._updateQueue[i]
        if node.taskId == newNode.taskId then
            if node.refreskKind == TaskListRefreshKind.Start then
                table.insert(self._updateQueue, newNode)
                return true
            elseif node.refreskKind > newNode.refreskKind then
                -- 已经有了更高优先级的, 低优先级的 就舍弃了
                return false
            elseif node.refreskKind < newNode.refreskKind then
                if
                    node.refreskKind == TaskListRefreshKind.SubFinish and
                        newNode.refreskKind == TaskListRefreshKind.Finish and
                        node.state == TaskQueueState.Prepare
                 then
                    self._updateQueue[i] = newNode
                else
                    table.insert(self._updateQueue, i + 1, newNode)
                end
                return true
            elseif node.refreskKind == newNode.refreskKind then
                if node.state ~= TaskQueueState.Prepare then
                    return false
                end
            end
        end
    end
    table.insert(self._updateQueue, newNode)
    return true
end

function TaskList:RunQueue()
    -- console.lzl('TaskList_LOG-------开始队列') --@DEL
    if Runtime.CSNull(self.gameObject) then
        return
    end
    local node = self._updateQueue[1]
    if not node then
        -- console.lzl('TaskList_LOG-------开始队列 没有节点 结束') --@DEL
        self:ReleaseBlock()
        return
    else
        -- console.lzl('TaskList_LOG-------开始队列 有节点', AppServices.Task:GetTaskName(node.taskId), TaskListRefreshKindName[node.refreskKind], TaskQueueStateName[node.state]) --@DEL
    end

    local nextNode = self._updateQueue[2]
    if
        nextNode and nextNode.taskId == node.taskId and node.refreskKind == TaskListRefreshKind.SubFinish and
            nextNode.refreskKind == TaskListRefreshKind.Finish and
            not node.JumpCallback
     then
        node.JumpCallback = true
        -- console.lzl('TaskList_LOG----下一个替代了新的') --@DEL
        table.remove(self._updateQueue, 1)
        self:RunQueue()
        return
    end

    if node.state == TaskQueueState.Running then
        return
    end

    if node.state == TaskQueueState.Finish then
        -- console.lzl('TaskList_LOG----删除节点', AppServices.Task:GetTaskName(node.taskId), TaskListRefreshKindName[node.refreskKind]) --@DEL
        table.remove(self._updateQueue, 1)
        self:RunQueue()
        return
    end
    if node.state < TaskQueueState.Running then
        node.state = TaskQueueState.Running
    end

    if not self:IsBlock() then
        self:StartBlock()
    end
    ---@type TaskListRefreshKind
    local kind = node.refreskKind
    local cbk = function()
        -- console.lzl('TaskList_LOG-------执行回调', AppServices.Task:GetTaskName(node.taskId), TaskListRefreshKindName[node.refreskKind], TaskQueueStateName[node.state], not not node.JumpCallback) --@DEL
        if Runtime.CSNull(self.gameObject) then
            return
        end
        node.state = TaskQueueState.Finish
        if node.refreskKind == TaskListRefreshKind.Finish then
            self:UpdateStoryProgress(node.taskId)
        end
        if not node.JumpCallback then
            self:RunQueue()
        end
    end
    if kind == TaskListRefreshKind.Start then
        self:AddNewTask(node.taskId, cbk)
    elseif kind == TaskListRefreshKind.SubFinish then
        local item = self:findItem(node.taskId)
        if item then
            item:RunQueueNode(node, cbk)
        else
            Runtime.InvokeCbk(cbk)
        end
    elseif kind == TaskListRefreshKind.Finish then
        local item = self:findItem(node.taskId)
        if not item then
            self:FocusTask(
                node.taskId,
                function(it)
                    -- console.lzl('TaskList_LOG 完成任务跳转 是否查到item', not not it) --@DEL
                    if it then
                        it:RunQueueNode(node, cbk)
                    else
                        Runtime.InvokeCbk(cbk)
                    end
                end
            )
        else
            item:RunQueueNode(node, cbk)
        end
    elseif kind == TaskListRefreshKind.Submit then
        self:RemoveTask(node.taskId, cbk)
    end
end

---开始阻止玩家操作
function TaskList:StartBlock()
    console.lzl("TaskList_LOG 开始Block", tostring(self._blocking)) --@DEL
    self._blocking = true
    self.list_srt.enabled = false
end

function TaskList:ReleaseBlock()
    console.lzl("TaskList_LOG 释放Block") --@DEL
    self._blocking = false
    self.list_srt.enabled = true
end

function TaskList:IsBlock()
    return self._blocking
end

function TaskList:findItem(taskId)
    for _, item in pairs(self.taskItemList) do
        if item.taskId == taskId then
            return item
        end
    end
end

function TaskList:AddNewTask(taskId, callback)
    -- console.lzl('TaskList_LOG-------AddNewTask', AppServices.Task:GetTaskName(taskId)) --@DEL
    local taskIdList = {}
    self._startTasks[taskId] = true
    for taskId in pairs(self._startTasks) do
        table.insert(taskIdList, taskId)
    end
    for _, taskIdx in pairs(self.indexList) do
        table.insertIfNotExist(taskIdList, self.index2TaskId[taskIdx])
    end
    taskIdList = AppServices.Task:SortTaskIds(taskIdList)

    local nextNode = self._updateQueue[2]
    if nextNode and nextNode.refreskKind == TaskListRefreshKind.Start then
        Runtime.InvokeCbk(callback)
    else
        self:SetLastFocusIndex(-1)
        self:InitList(taskIdList)
        -- self:ResetList(taskIdList)
        self._starTaskTimer =
            WaitExtension.SetTimeout(
            function()
                self._starTaskTimer = nil
                Runtime.InvokeCbk(callback)
            end,
            0.3
        )
    end
end

---删除一个任务
function TaskList:RemoveTask(taskId, callback)
    local index = table.kvfind(self.index2TaskId, taskId)
    local item = self:findItem(taskId)
    -- console.lzl("TaskList_LOG RemoveTask", AppServices.Task:GetTaskName(taskId), tostring(index), '是否有item', not not item) --@DEL
    if not item then
        self.list_container:RemoveItem(index)
        Runtime.InvokeCbk(callback)
        return
    end
    if self._weakGuideTaskId == taskId then
        self._weakGuideTaskId = nil
    end
    if self._showingKey and item.key == self._showingKey then
        self:HideTaskDetailInfo()
    end
    -- console.lzl('TaskList_LOG 删除的任务 key', item.key, 'index', index) --@DEL
    item:PlayFinishAnimation(
        function()
            local item = self:findItem(taskId)
            if item and Runtime.CSValid(self.list_container) then
                self.list_container:RemoveItem(index)
            end
            if item then
                item:ResetScale()
            end
            WaitExtension.InvokeDelay(callback)
        end
    )
end

local _offsetX = 300
function TaskList:ShowExitAnim(instant)
    self.isEnter = false
    self:HideTaskDetailInfo()
    self:HideListArrow()
    DOTween.Kill(self.rectTransform, false)
    if instant then
        self.rectTransform.anchoredPosition =
            Vector2(self.originalAnchoredPosX - _offsetX, self.rectTransform.anchoredPosition.y)
    else
        GameUtil.DoAnchorPosX(self.rectTransform, self.originalAnchoredPosX - _offsetX, 0.5)
    end
    -- self:EndWeakGuide()
end

function TaskList:ShowEnterAnim(instant)
    -- self:EnableClick(true)

    DOTween.Kill(self.rectTransform, false)
    if instant then
        self.rectTransform.anchoredPosition = Vector2(self.originalAnchoredPosX, self.rectTransform.anchoredPosition.y)
        -- console.lzl("TaskList_LOG 列表进来1") --@DEL
        self.isEnter = true
        self:RunQueue()
        self:CheckListArrow()
    else
        GameUtil.DoAnchorPosX(
            self.rectTransform,
            self.originalAnchoredPosX,
            0.2,
            function()
                -- console.lzl("TaskList_LOG 列表进来2") --@DEL
                self.isEnter = true
                self:RunQueue()
                self:CheckListArrow()
            end
        )
    end
    -- self:StartWeakGuide()
end

function TaskList:JumpTask(params)
    local showTaskId = params.showTaskId
    local tipFindTaskId = params.tipFindTaskId
    if tipFindTaskId then
        local taskName = AppServices.Task:GetTaskName(tipFindTaskId)
        local str = Runtime.Translate("ui_taskunlock_des2", {taskname = taskName})
        AppServices.UITextTip:Show(str, 1.686)
    end
    local findItem = false
    for _, item in pairs(self.taskItemList) do
        item:HideArrow()
        if item.taskId == showTaskId then
            findItem = true
            item:ShowArrow()
        end
    end
    if not findItem then
        self:FocusTask(
            showTaskId,
            function()
                local item = self:findItem(showTaskId)
                if item then
                    item:ShowArrow()
                end
            end
        )
    end
end

function TaskList:FocusTask(taskId, callback)
    local index = table.kvfind(self.index2TaskId, taskId)
    -- console.lzl("TaskList_LOG_FocusTask", AppServices.Task:GetTaskName(taskId), index, taskId, table.serialize(self.index2TaskId)) --@DEL
    if not index then
        Runtime.InvokeCbk(callback)
        return
    end
    self.list_container:MoveTargetItemByIndex(
        index,
        0,
        function()
            WaitExtension.SetTimeout(
                function()
                    local item = self:findItem(taskId)
                    if item then
                        Runtime.InvokeCbk(callback, item)
                    else
                        Runtime.InvokeCbk(callback)
                    end
                end,
                0.5
            )
        end
    )
end

function TaskList:SetLastFocusIndex(index)
    -- console.lzl("TaskList_LOG 设置LastFocusIndex", index) --@DEL
    self._lastFocusIndex = index
end

function TaskList:GetLastFocusIndex()
    return self._lastFocusIndex
end

function TaskList:ShowBuildingTaskTip(taskId, subIndex, key)
    if not self._taskDetailInfo then
        return
    end
    local fullCfg = AppServices.Task:GetFullConfig(taskId)
    local subCfg = fullCfg.SubMissions[subIndex]
    local sceneId = subCfg.ZoneId
    local agentId = subCfg.BuildingId
    local level = AppServices.BuildingRepair:GetLevel(sceneId, agentId, true)
    if not level then
        AppServices.BuildingRepair:GetBuildingLevelFromNet(sceneId, agentId, subCfg.ObstacleTemplateId)
        return
    else
        local subCfg = fullCfg.SubMissions[subIndex]
        local templateId = subCfg.ObstacleTemplateId
        -- local taskDetail = self.detailListItems[key]
        local taskDetailInfo = self._taskDetailInfo
        if taskDetailInfo then
            local parentGameObject = taskDetailInfo:GetSubGameObject(subIndex)
            UITool.ShowBuildingTaskTip(self, sceneId, agentId, templateId, level, parentGameObject, {align = "rm"})
        end
    end
end

function TaskList:GetIdleGo()
    -- TODO Guide 得去self.taskList里找对应的TaskSlot对象
end

function TaskList:GetRedDotGo()
    -- TODO Guide 得去self.taskList里找对应的TaskSlot对象
    -- local item = self:findItem(taskId)
    local _, item = next(self.taskItemList)
    if item then
        return item.img_reddot.gameObject
    end
end

function TaskList:SetWeakGuideActive()
end

function TaskList:StartTick()
    if not self._tickTimer then
        self._tickTimer =
            WaitExtension.InvokeRepeating(
            function()
                self:OnTick()
            end,
            0,
            1
        )
        self:OnTick()
    end
end

function TaskList:RegisterKeyListener()
    App.scene:Unregister(self, "LateUpdate")
    App.scene:Register(
        self,
        "LateUpdate",
        function()
            self:OnOperate()
        end
    )
end

function TaskList:OnOperate()
    local operate
    if RuntimeContext.VERSION_DISTRIBUTE then
        operate = CS.UnityEngine.Input.touchCount > 0
    else
        operate = CS.UnityEngine.Input:GetMouseButtonDown(0)
    end
    if operate then
        if not self:IsInWeakGuideCD() then
            -- console.lzl("TaskList_LOG WeakGuide:OnOperate") --@DEL
            self:BreakWeakGuide()
        end
    end
end

function TaskList:OnTick()
    self:CheckWeakGuide()
end

function TaskList:CheckWeakGuide()
    if App:IsScreenPlayActive() then
        return
    end

    if App.mapGuideManager:HasRunningGuide() then
        return
    end

    if self:IsInWeakGuideCD() then
        return
    end
    if self._weakGuideTaskId then
        self:CheckShowWeakGuide()
        return
    end
    if not self.index2TaskId then
        return
    end

    for _, taskId in pairs(self.index2TaskId) do
        local cfg = AppServices.Task:GetFullConfig(taskId)
        if cfg and cfg.WeakGuide then
            if self._showingKey then
                local item = self.taskItemList[self._showingKey]
                if item and item.taskId == taskId then
                    return
                end
            end
            self._weakGuideTaskId = taskId
            local cdTime = AppServices.Meta:GetConfigMetaValueNumber("taskGuideCd", 10)
            self._weakGuideStartTime = TimeUtil.ServerTime() + cdTime
            self:CheckShowWeakGuide()
            break
        end
    end
end

function TaskList:CheckShowWeakGuide()
    if not self._weakGuideTaskId then
        return
    end
    if self._weakGuideStartTime and self._weakGuideStartTime < TimeUtil.ServerTime() then
        self:BreakWeakGuide()
        return
    end
    local item = self:findItem(self._weakGuideTaskId)
    if item then
        if not item._weakGuiding then
            item:StartShowWeakGuide()
        end
    end
end

function TaskList:IsInWeakGuideCD()
    if not self._weakGuideCdOverTime then
        return false
    end
    return self._weakGuideCdOverTime > TimeUtil.ServerTime()
end

function TaskList:ActionWeakGuideCD()
    local cdTime = AppServices.Meta:GetConfigMetaValueNumber("taskGuideCd", 10)
    self._weakGuideCdOverTime = TimeUtil.ServerTime() + cdTime
end

function TaskList:BreakWeakGuide()
    self._weakGuideTaskId = nil
    self:ActionWeakGuideCD()
    self:StopWeakGuide()
end

function TaskList:StopWeakGuide()
    for _, item in pairs(self.taskItemList) do
        if item._weakGuiding then
            item:StopShowWeakGuide()
        end
    end
end

function TaskList:ShowRedDot()
end

function TaskList:NeedWeakGuide()
end

function TaskList:CheckListArrow()
    if not self.showlistArrow then
        return
    end
    self:ShowListArrow()
end

function TaskList:TriggerListArrow()
    self.showlistArrow = true
end

function TaskList:ShowListArrow()
    if self.listArrowId then
        WaitExtension.CancelTimeout(self.listArrowId)
        self.listArrowId = nil
    end
    self.showlistArrow = nil
    self:BreakWeakGuide()
    if Runtime.CSValid(self.arrow) then
        self.arrow:SetActive(true)
    end
    local sec = 0
    self.listArrowId =
        WaitExtension.InvokeRepeating(
        function()
            sec = sec + 1
            if sec >= 2 then
                self:HideListArrow()
            end
        end,
        0,
        1
    )
end

function TaskList:HideListArrow()
    if self.listArrowId then
        WaitExtension.CancelTimeout(self.listArrowId)
        self.listArrowId = nil
    end
    self.showlistArrow = false
    if Runtime.CSValid(self.arrow) then
        self.arrow:SetActive(false)
    end
end

function TaskList:GetAxisYLimit()
    local go_list = self.list_container.gameObject
    local trans = go_list.transform
    local position = go_list:GetPosition()
    local startPos = GOUtil.WorldPositionToLocal(self.gameObject, position)
    --上沿
    local yUp = startPos.y + (trans.pivot.y * trans.sizeDelta.y)
    --下沿
    local yDown = startPos.y - (trans.pivot.y * trans.sizeDelta.y)
    return yUp, yDown
end

function TaskList:Dispose()
    -- console.lzl("TaskList_LOG Dispose TaskList")--@DEL
    if Runtime.CSValid(self.list_container) then
        self.list_container:Destroy()
        self.list_container = nil
    end
    for _, item in pairs(self.taskItemList) do
        item:destroy()
    end
    if self._tickTimer then
        WaitExtension.CancelTimeout(self._tickTimer)
        self._tickTimer = nil
    end
    App.scene:Unregister(self, "LateUpdate")
    if self._starTaskTimer then
        WaitExtension.CancelTimeout(self._starTaskTimer)
        self._starTaskTimer = nil
    end
    if self.WeakGuide ~= nil then
        self.WeakGuide:End()
        self.WeakGuide = nil
    end
    if self._taskDetailInfo then
        self._taskDetailInfo:destroy()
        self._taskDetailInfo = nil
    end
    self:HideListArrow()
    MessageDispatcher:RemoveMessageListener(MessageType.PopupQueue_FINISHED, self.CheckListArrow, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Task_ActivityTaskConfig_Loaded, self.CheckActivityTaskOver, self)
    App.scene:Unregister(self, "OnLanguageChanged")
    BaseIconButton.Dispose(self)
end

return TaskList
