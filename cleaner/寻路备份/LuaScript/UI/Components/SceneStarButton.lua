local SceneStarShowData = {}
SceneStarShowData.data = {}

SceneStarShowData.GetShowStar = function(sceneId, starIndex)
    if SceneStarShowData.data[sceneId] == nil then
        SceneStarShowData.data[sceneId] = {}
        for i = 1, SCENE_STAR_NUM do
            SceneStarShowData.data[sceneId][i] = AppServices.MapStarManager:IsStarDone(sceneId, i)
        end
    end
    return SceneStarShowData.data[sceneId][starIndex]
end

SceneStarShowData.SetShowStar = function(sceneId, starIndex)
    if SceneStarShowData.data[sceneId] == nil then
        SceneStarShowData.data[sceneId] = {}
    end
    SceneStarShowData.data[sceneId][starIndex] = true
end

SceneStarShowData.NeedUpdata = function(sceneId)
    if SceneStarShowData.data[sceneId] == nil then
        return true
    end
    for i = 1, SCENE_STAR_NUM do
        if not SceneStarShowData.data[sceneId][i] and AppServices.MapStarManager:IsStarDone(sceneId, i) then
            return true
        end
    end
    return false
end

local Supper = require "UI.Components.BaseIconButton"
---@class SceneStarButton:LuaUiBase
local SceneStarButton = class(Supper)

function SceneStarButton.Create()
    local go = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_SceneStar_BUTTON)
    local btn = SceneStarButton.new()
    btn:Init(go)
    return btn
end

function SceneStarButton:Init(go)
    self.gameObject = go
    self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
    self.isEntered = true
    self.needUpdateRedDot = true
    local mapStarManager = AppServices.MapStarManager
    local sceneId = App.scene:GetCurrentSceneId()
    self.sceneId = sceneId
    self.titleStarAry = {}
    self._popBarQueue = {}
    -- self._isShow = true
    for i = 1, 3 do
        self.titleStarAry[i] = {}
        self.titleStarAry[i].go_starLight = go.transform:Find(string.format("icons/star%s/go_starLight", i)).gameObject
        self.titleStarAry[i].go_starGrey = go.transform:Find(string.format("icons/star%s/go_starGrey", i)).gameObject
    end
    self.c2_time = go.transform:Find("c2_time").gameObject
    self.text_time = go.transform:Find("c2_time/text_time"):GetComponent(typeof(Text))
    -- self.poptips_go = go:FindGameObject("mask/poptips")
    -- self.go_pop_done = self.poptips_go:FindGameObject("img_pop_done")
    -- self.go_pop_progress = self.poptips_go:FindGameObject("img_pop_progress")
    -- self.label_done = find_component(self.go_pop_done, 'label_done', Text)
    -- self.label_progress = find_component(self.go_pop_progress, 'label_progress', Text)
    self.mask = find_component(go, "mask")
    self.bar = find_component(self.mask, "bar")
    self.txt_done = find_component(self.bar, "bg/bg_done/Text", Text)
    self.txt_process = find_component(self.bar, "bg/bg_progress/Text", Text)
    self.img_barIcon = find_component(self.bar, "bg/icon_img", Image)
    self.rawImg_barIcon = find_component(self.bar, "bg/icon_rawImg", RawImage)
    self.bg_done = find_component(self.bar, "bg/bg_done", Image)
    self.bg_progress = find_component(self.bar, "bg/bg_progress", Image)
    self.go_reddot = go.transform:Find("img_reddot").gameObject
    --local starCount = SceneStarShowData.GetShowStar(sceneId)
    for i = 1, #self.titleStarAry do
        local titleStar = self.titleStarAry[i]
        local done = SceneStarShowData.GetShowStar(sceneId, i)
        titleStar.go_starLight:SetActive(done)
        titleStar.go_starGrey:SetActive(not done)
    end
    self.isLimitTimeRewarded = AppServices.MapStarManager:IsLimitTimeRewarded(self.sceneId)
    local limitTime = mapStarManager:GetLimitTime(sceneId) / 1000
    local difftime
    local setLimitTime = function()
        difftime = math.floor(limitTime - TimeUtil.ServerTime())
        if not self.isLimitTimeRewarded and difftime >= 0 then
            --[[if hour < 1 then
                self.text_time.color = Color.red
            end--]]
            local hour = math.floor(difftime / 3600)
            local min = math.floor((difftime - hour * 3600) / 60)
            local sec = math.fmod(difftime, 60)
            self.text_time.text = string.format("%02d:%02d:%02d", hour, min, sec)
        else
            self.c2_time:SetActive(false)
            if self.updateTimeId ~= nil then
                WaitExtension.CancelTimeout(self.updateTimeId)
                self.updateTimeId = nil
            end
        end
    end
    setLimitTime()
    if difftime >= 0 then
        self.updateTimeId = WaitExtension.InvokeRepeatingNextFrame(setLimitTime, 1)
    end

    local function onClick()
        self:OnBtnClick()
    end
    Util.UGUI_AddButtonListener(go, onClick)
    MessageDispatcher:AddMessageListener(MessageType.Task_OnSubTaskFinish, self.OnTaskProgress, self)
    MessageDispatcher:AddMessageListener(MessageType.Task_OnSubTaskAddProgress, self.OnTaskProgress, self)
    -- MessageDispatcher:AddMessageListener(MessageType.Task_OnTaskFinish, self.OnTaskFinish, self)
    MessageDispatcher:AddMessageListener(MessageType.MapStar_StarTask_AllDone, self.OnMapStarTaskAllDone, self)
    MessageDispatcher:AddMessageListener(MessageType.MapStar_3Star_Done, self.OnMapStar3StarDone, self)
    self:ShowEnterAnim()
end

function SceneStarButton:CheckGuide()
    if AppServices.MapStarManager:GetSceneStar("2") > 1 then
        App.mapGuideManager:MarkGuideComplete(GuideIDs.GuideSceneStar)
        return
    end

    local function idleDo()
        self.checking = nil
        if
            Runtime.CSValid(self.go_reddot) and self.go_reddot.activeInHierarchy and
                not App.mapGuideManager:HasComplete(GuideIDs.GuideSceneStar)
         then
            Util.BlockAll(0.5, "StartSeries_GuideSceneStar")
            WaitExtension.SetTimeout(
                function()
                    Util.BlockAll(0, "StartSeries_GuideSceneStar")
                    if not PopupManager:IsIdleMainCity() then
                        self:CheckGuide()
                        return
                    end
                    App.mapGuideManager:StartSeries(GuideIDs.GuideSceneStar, {starButton = self})
                end,
                0.3
            )
        end
    end
    if self.checking then
        return
    end
    self.checking = true
    PopupManager:CallWhenIdle(idleDo)
end

function SceneStarButton:OnBtnClick()
    self.needUpdateRedDot = true
    PanelManager.showPanel(GlobalPanelEnum.SceneStarPanel)
end

function SceneStarButton:ShowStarAnim()
    if not self.isEntered then
        return
    end
    if not SceneStarShowData.NeedUpdata(self.sceneId) then
        return
    end
    self:StopStarAnim()
    local showIndex = {}
    for i = 1, #self.titleStarAry do
        local done = AppServices.MapStarManager:IsStarDone(self.sceneId, i)
        if done and not SceneStarShowData.GetShowStar(self.sceneId, i) then
            table.insert(showIndex, i)
            SceneStarShowData.SetShowStar(self.sceneId, i)
        end
    end
    self.timeId1 =
        WaitExtension.SetTimeout(
        function()
            self.timeId1 = nil
            for _, i in ipairs(showIndex) do
                local titleStar = self.titleStarAry[i]
                titleStar.go_starLight:SetActive(true)
                titleStar.go_starLight.transform.localScale = Vector3(0.2, 0.2, 0.2)
                titleStar.go_starLight.transform:DOScale(1, 0.6)
            end
        end,
        0.4
    )
    self.timeId2 =
        WaitExtension.SetTimeout(
        function()
            self.timeId2 = nil
            for _, i in ipairs(showIndex) do
                local titleStar = self.titleStarAry[i]
                titleStar.go_starGrey:SetActive(false)
            end
        end,
        1
    )
end

function SceneStarButton:StopStarAnim()
    if self.timeId1 ~= nil then
        WaitExtension.CancelTimeout(self.timeId1)
        self.timeId1 = nil
    end
    if self.timeId2 ~= nil then
        WaitExtension.CancelTimeout(self.timeId2)
        self.timeId2 = nil
    end
    --local showCount = SceneStarShowData.GetShowStar(self.sceneId)
    for i = 1, #self.titleStarAry do
        local titleStar = self.titleStarAry[i]
        if SceneStarShowData.GetShowStar(self.sceneId, i) then
            titleStar.go_starLight.transform.localScale = Vector3(1, 1, 1)
            titleStar.go_starGrey:SetActive(false)
        end
    end
end

function SceneStarButton:pushPopBar(cur, total, taskId, desc)
    local popInfo = {
        cur = cur,
        total = total,
        -- icon = icon,
        -- icon_way = icon_way,
        desc = desc,
        taskId = taskId
    }
    table.insert(self._popBarQueue, popInfo)
    self:checkPopBar()
end

function SceneStarButton:BatchPopBegin(needCount)
    if needCount then
        self._batchPopCount = (self._batchPopCount or 0) + 1
    -- console.lzl('---BatchPopBegin-', self._batchPopCount)
    end
    self._isBatchPop = true
end

function SceneStarButton:BatchPopOver(needCount)
    if self._batchPopCount then
        self._batchPopCount = math.max(self._batchPopCount - 1, 0)
    -- console.lzl('---BatchPopOver-', self._batchPopCount)
    end
    if not needCount or (not self._batchPopCount or self._batchPopCount <= 0) then
        self._isBatchPop = false
        self:checkPopBar()
    end
end

function SceneStarButton:checkPopBar()
    if not self.isEntered or self._isBatchPop then
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
function SceneStarButton:mergeSamePop()
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

function SceneStarButton:PopBar(popInfo)
    -- local icon_way = popInfo.icon_way
    -- local viewCom = nil
    if Runtime.CSNull(self.mask) then
        return
    end
    local parent = self.gameObject:GetParent()
    self.mask:SetParent(parent)
    self.mask.transform:SetAsLastSibling()
    self.mask:SetActive(true)

    -- self.rawImg_barIcon:SetActive(icon_way == 'task')
    -- self.img_barIcon:SetActive(icon_way == 'item')
    -- if icon_way == 'task' then
    --     viewCom = self.rawImg_barIcon
    -- elseif icon_way == 'item' then
    --     viewCom = self.img_barIcon
    -- end
    -- ActivityServices.GoldPass:SetGoldPassTaskIcon(viewCom, popInfo.icon, popInfo.icon_way)
    -- console.lzl('-----popbar', popInfo.taskId, popInfo.cur)
    local str =
        string.format("%s %s", Runtime.Translate(popInfo.desc), Runtime.formartCount(popInfo.cur, popInfo.total))
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
        0,
        0.8,
        function()
            self:HideBar()
        end
    )
end

function SceneStarButton:HideBar()
    if not Runtime.CSValid(self.bar) then
        return
    end
    self.delayHideId =
        WaitExtension.SetTimeout(
        function()
            if self.delayHideId then
                WaitExtension.CancelTimeout(self.delayHideId)
                self.delayHideId = nil
            end
            local trans = self.bar.transform
            GameUtil.DoAnchorPosX(
                trans,
                -trans.sizeDelta.x,
                0.8,
                function()
                    self._isPoping = nil
                    if Runtime.CSNull(self.bar) then
                        return
                    end
                    self.mask:SetActive(false)
                    self.mask:SetParent(self.gameObject:GetParent())
                    self:checkPopBar()
                end
            )
        end,
        0.5
    )
end

function SceneStarButton:ShowExitAnim(exitImmediate, callback)
    self.isEntered = false
    self.mask:SetActive(false)
    -- self.poptips_go:SetActive(false)
end

function SceneStarButton:ShowEnterAnim(callback, showTime)
    self.isEntered = true
    self.isLimitTimeRewarded = AppServices.MapStarManager:IsLimitTimeRewarded(self.sceneId)
    self:ShowStarAnim()
    self:checkPopBar()
    self:TryGetStarTimeReward()
    -- self.poptips_go:SetActive(true)
    if self.needUpdateRedDot then
        self.needUpdateRedDot = false
        self:SetRedDot()
    end
end

-- function SceneStarButton:OnSubTaskFinish(taskKind, taskId, sceneId)
--     if taskKind ~= TaskKind.MapStar then
--         return
--         -- self:ShowPopBar(true)
--     end
--     self:pushPopBar(cur, total, taskId)
-- end

function SceneStarButton:OnTaskProgress(taskKind, taskId, sceneId)
    if taskKind ~= TaskKind.MapStar then
        return
    end
    if sceneId ~= App.scene:GetCurrentSceneId() then
        return
    end
    -- self:ShowPopBar(false)
    local taskEntity = AppServices.MapStarManager:GetTaskEntity(sceneId, taskId)
    local total = taskEntity:GetTotal()
    local cur = taskEntity:GetProgress()
    local taskCfg = AppServices.MapStarManager:GetTaskConfig(taskId)
    cur = math.min(cur, total)
    self:pushPopBar(cur, total, taskId, taskCfg.progressKey)
end

function SceneStarButton:OnMapStarTaskAllDone()
    if Runtime.CSNull(self.gameObject) then
        self:Dispose()
        return
    end

    self:SetRedDot()
    self:CheckGuide()
    if self.isEntered then
        self:ShowStarAnim()
    end
end

function SceneStarButton:OnMapStar3StarDone()
    if self.isEntered then
        self:TryGetStarTimeReward()
    end
end

function SceneStarButton:SetRedDot()
    for i = 1, SCENE_STAR_NUM do
        if AppServices.MapStarManager:CanGetStarReward(self.sceneId, i) then
            self.go_reddot:SetActive(true)
            return
        end
    end
    self.go_reddot:SetActive(false)
end

function SceneStarButton:StopAllCor()
    if self.updateTimeId ~= nil then
        WaitExtension.CancelTimeout(self.updateTimeId)
        self.updateTimeId = nil
    end
    if self._hideTimer then
        WaitExtension.CancelTimeout(self._hideTimer)
        self._hideTimer = nil
    end
    self:StopStarAnim()
end

function SceneStarButton:TryGetStarTimeReward()
    PopupManager:CallWhenIdle(function()
        if AppServices.MapStarManager:GetSceneStar(self.sceneId) == SCENE_STAR_NUM then
            for i = 1, SCENE_STAR_NUM do
                if AppServices.MapStarManager:CanGetStarReward(self.sceneId, i) then
                    self.needUpdateRedDot = true
                    PanelManager.showPanel(GlobalPanelEnum.SceneStarPanel, {isAuto = true})
                    return
                end
            end
        end
    end
    )
end

function SceneStarButton:Dispose()
    MessageDispatcher:RemoveMessageListener(MessageType.Task_OnSubTaskFinish, self.OnTaskProgress, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Task_OnSubTaskAddProgress, self.OnTaskProgress, self)
    -- MessageDispatcher:RemoveMessageListener(MessageType.Task_OnTaskFinish, self.OnTaskFinish, self)
    MessageDispatcher:RemoveMessageListener(MessageType.MapStar_StarTask_AllDone, self.OnMapStarTaskAllDone, self)
    MessageDispatcher:RemoveMessageListener(MessageType.MapStar_3Star_Done, self.OnMapStar3StarDone, self)
    self:StopAllCor()
    self.super.Dispose(self)
    if Runtime.CSValid(self.mask) then
        Runtime.CSDestroy(self.mask)
        self.mask = nil
    end
end

return SceneStarButton
