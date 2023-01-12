---
--- Created by Betta.
--- DateTime: 2022/1/17 16:25
---
local SceneStarRewardItem = require("UI.SceneStarPanel.View.UI.SceneStarRewardItem")
local SceneStarTaskItem = class(nil, "SceneStarTaskItem")

function SceneStarTaskItem:ctor(go, taskCfg)
    self:InitView(go)
    self.cfg = taskCfg
    self:SetData(taskCfg)
end

function SceneStarTaskItem:InitView(go)
    self.text_des = go.transform:Find("text_des"):GetComponent(typeof(Text))
    self.go_done = go.transform:Find("go_done").gameObject
    self.go_jump = go.transform:Find("go_jump").gameObject
end

function SceneStarTaskItem:SetData(taskCfg)
    local sceneId = App.scene:GetCurrentSceneId()
    self.text_des.text = Runtime.Translate(taskCfg.taskDesc)
    local taskEntity = AppServices.MapStarManager:GetTaskEntity(sceneId, taskCfg.id)
    if taskEntity then
        local isDone = taskEntity:IsDone()
        self.go_done:SetActive(taskEntity:IsDone())
        self.go_jump:SetActive(not isDone)
        local num1 = taskEntity:GetProgress()
        if isDone then
            num1 = "<color=#31ab15>" .. taskEntity:GetTotal() .."</color>"
        end
        self.text_des.text = string.format("%s(%s/%s)", Runtime.Translate(taskCfg.taskDesc), num1, tostring(taskEntity:GetTotal()))
    else
        self.go_done:SetActive(false)
        self.go_jump:SetActive(false)
        self.text_des.text = Runtime.Translate(taskCfg.taskDesc)
    end
    --GameUtil.FitTextContentSize(self.text_des)
    Util.UGUI_AddButtonListener(self.go_jump, function()
        PanelManager.closePanel(GlobalPanelEnum.SceneStarPanel)
        AppServices.JumpTask.MissionType[taskCfg.missionType](taskCfg)
        --AppServices.Jump.ActivityToTask(taskCfg)
    end)
end

---@class SceneStarItem
local SceneStarItem = class(nil, "StarItem")

function SceneStarItem:ctor(go, taskCfg, starIndex)
    self:InitView(go)
    local sceneId = App.scene:GetCurrentSceneId()
    self.taskAry = {}
    for i = 1, 3 do
        local child = go.transform:Find("task/task"..i).gameObject
        if i > #taskCfg.taskConfigs then
            child:SetActive(false)
        else
            self.taskAry[i] = SceneStarTaskItem.new(child, taskCfg.taskConfigs[i])
        end
    end
    for i = 1, 2 do
        local child = go.transform:Find("task/line"..i).gameObject
        if i >= #taskCfg.taskConfigs then
            child:SetActive(false)
        end
    end
    local isStarRewarded = AppServices.MapStarManager:IsStarRewarded(sceneId, starIndex)
    ---@type SceneStarRewardItem[]
    self.rewardAry = {}
    for i = 1, 2 do
        local child = go.transform:Find("rewards/reward"..i).gameObject
        if i > #taskCfg.rewards then
            child:SetActive(false)
        else
            self.rewardAry[i] = SceneStarRewardItem.new(child, taskCfg.rewards[i], isStarRewarded)
        end
    end
    --local IsStarDone =  AppServices.MapStarManager:IsStarDone(sceneId, starIndex)
    --self.go_starLight:SetActive(not isStarRewarded)
    --self.go_starGrey:SetActive(not IsStarDone)
    self.text_title.text = Runtime.Translate("UI_star_task_title", {num = tostring(starIndex)})
    self.text_reward.text = Runtime.Translate("ui_mail_detail_reward")
end

function SceneStarItem:InitView(go)
    --self.go_starLight = go.transform:Find("go_starLight").gameObject
    --self.go_starGrey = go.transform:Find("go_starGrey").gameObject
    self.text_title = go.transform:Find("text_title"):GetComponent(typeof(Text))
    self.text_reward = go.transform:Find("text_reward"):GetComponent(typeof(Text))
end

function SceneStarItem:SetGetReward()
    for _, reward in ipairs(self.rewardAry) do
        reward:SetGetReward()
    end
end

function SceneStarItem:RefreshTask(taskId)
    for _, task in ipairs(self.taskAry) do
        if task.cfg.id == taskId then
            task:SetData(task.cfg)
        end
    end
end

return SceneStarItem
