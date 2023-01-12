---@class popupForceQueuePriority
popupForceQueuePriority = {
    --版本更新
    -- "AppUpdate",
    -- 版本更新奖励
    "AppUpdateReward",
    --绑定FB账号送体力
    "FbBindReward",
    -- 检查任务切场景
    "CheckTaskChangeScene",
    --检测活动列表
    "Activity",
    --检测等级地图活动列表
    "LevelMapActivity",
    --魔法生物
    --"CheckCreateMagical",
    "CheckMagicalProfit",
    --场景关闭信息 ----新的机制直接提前获取消息了，不需要再在队列里执行了
    --"CheckSceneCloseInfo",
    --兑换关闭场景道具
    "ExchangeCloseSceneItems",
    --邮箱
    "ExpireMailRewards",
    "Mail",
    "TaskCheck",
    "CheckTaskPreDrama",
    --每日签到奖励
    "DayReward",
    --引导
    "GuideEvent_EnterCity",
    "Guide",
    -- "PostGuide",
    ---检查头像下面的建筑修复监听
    --"CheckBuildingTaskTipButtons",
    ---检查道具收藏的建筑冒泡
    --"CollectionItemBubbleCheck",
    --跟货币相关的都放在这个之后
    "InitPurchase",
    "CheckRuinsScene",
    ---显示礼包
    "ShowGift",
    ---轮循图
    "GiftFrame",
    ---强弹升级礼包
    "GrowthFund",
    ---小猪存钱罐
    "PiggyBank",
    ---检查月卡过期
    "CheckMonCard",
    --"Activity",
    --通行证活动结束后的提示弹窗
    "CheckGoldPassEndPopup",
    --队列检测触发通行证引导（策划需求）
    "CheckGoldPassGuide",
    ---龙PVE活动结束界面
    "CheckDragonExploitEndPanel",
    "CheckParkourEndPanel",
    "CheckMowEndPanel",
    --检查重开地图是否已结束
    "CheckReopenMapEnd",
    ---检查跳转场景的callback, 注意：跳转场景必须是最后一个，这里队列是直接放开的，所以新加的都在其上面
    "CheckAutoJumpCbk",
    --"ShowTaskListArrow",
    ---检查稻草人
    --"CheckScarecrow",
    ---检查拯救小动物
    "CheckSaveAnimal",
    ---检查装扮小屋引导
    -- "SkinEquipGuide",
    --"CheckDebugBtn"
    "CheckDressingHut",
    ---检查依赖于其他数据的任务进度
    "CheckTasksDependOnOtherData",
    ---迷宫升级弹窗
    "MazeUpLevel",
    ---检查开了通行证之后, 补发公会活动累积积分的双倍奖励
    "CheckGoldPassTeamActivityScoreDoubleReward",

}
--require("System.Core.popupJob.PopupJob")

---@class PopupQueue
PopupQueue = class()
PopupQueue_isInWork = false
function PopupQueue:Create()
    local instance = PopupQueue.new()
    --instance:Init()
    return instance
end

function PopupQueue:ctor()
    self.jobLogicList = {}
    for _, priority in pairs(popupForceQueuePriority) do
        self.jobLogicList[priority] = require("System.Core.popupJob.Job_"..priority)
    end
    self.isFinish = false
end

function PopupQueue:Init()
    self.workQueue = {}
    self.workIndex = 1
    self.workTotal = #popupForceQueuePriority

    for index, priority in ipairs(popupForceQueuePriority) do
        local job = self.jobLogicList[priority]
        --local job = JobLogic.new()
        job:Init(priority)
        self.workQueue[index] = job
    end

    self.totalStartTime = Time.realtimeSinceStartup --@DEL

    PopupQueue_isInWork = true
    self:ExecuteJob()
end

function PopupQueue:ExecuteJob()
    if not PopupQueue_isInWork then
        return
    end

    local function CheckJobNeedDo(job)
        local result = false
        if not job then
            console.lj("JOB error:"..self.workIndex.."不存在") --@DEL
            return result
        end

        --检查当前JOB是否需要执行
        local luaState = Runtime.InvokeCbk(function ()
            result = job:CheckPop()
        end)

        --异常保护，代码发生错误强行跳过
        if not luaState then
            console.error("错误：JOB"..self.workIndex.." 检查流程代码报错:"..job.name) --@DEL
            job.isError = true
            --如果代码错误强行跳过
            result = true
        end
        return result
    end

    --检查出需要强弹的job
    local isEndNoJob = true
    Util.BlockAll(-1, "PopupQueue")
    for index = self.workIndex, self.workTotal do
        local job = self.workQueue[index]
        if CheckJobNeedDo(job) then
            self.workIndex = index
            isEndNoJob = false
            break
        else
            Runtime.InvokeCbk(job.DoEnd, job)
        end
    end

    --如果没有强弹，直接结束
    if isEndNoJob then
        if RuntimeContext.VERSION_DEVELOPMENT then
            --队列全部执行完
            console.lj("PopupQueue Success Finished") --@DEL
            console.lj("一共消耗时间:"..string.format("%.4f", Time.realtimeSinceStartup - self.totalStartTime)) --@DEL
            UITool.ShowContentTipAni("VERSION_DEVELOPMENT Tip:PopupQueue Success Finished")--@DEL
        end
        MessageDispatcher:SendMessage(MessageType.PopupQueue_FINISHED)
        self:Clear(true)
        self.isFinish = true
        return
    end

    --执行单个强弹事件,直到结束
    local workJob = self.workQueue[self.workIndex]
    console.lj("JOB"..self.workIndex.." 触发强制流程:"..workJob.name) --@DEL
    self.startTime = Time.realtimeSinceStartup --@DEL
    WaitExtension.InvokeDelay(function ()
        Util.BlockAll(0, "PopupQueue")
        SceneLog:Add("PopupQueue",workJob.name,false) --@DEL
        local result = Runtime.InvokeCbk(workJob.Do, workJob,function ()
            Runtime.InvokeCbk(workJob.DoEnd,workJob)
            self:FinishJob()
        end)
        if not result then
            console.error("错误：JOB"..self.workIndex.." 执行流程代码报错:"..workJob.name) --@DEL
            workJob.isError = true
            Runtime.InvokeCbk(workJob.DoEnd,workJob)
            return self:FinishJob()
        end
    end)
end

function PopupQueue:FinishJob()
    if RuntimeContext.VERSION_DEVELOPMENT then
        console.lj("JOB"..self.workIndex.." 消耗时间:"..string.format("%.4f", Time.realtimeSinceStartup - self.startTime)) --@DEL
        local job = self.workQueue[self.workIndex] --@DEL
        if job and not job.isError then --@DEL
            SceneLog:Add("PopupQueue",job.name,true) --@DEL
        end --@DEL
    end
    self.workIndex = self.workIndex + 1
    return self:ExecuteJob()
end

function PopupQueue:Clear(isFinish)
    if PopupQueue_isInWork and not isFinish then
        console.lj("JOB 队列强制结束")
    end
    self.workIndex = 1
    self.workQueue = {}
    PopupQueue_isInWork = false
    self.isFinish = false
    Util.BlockAll(0, "PopupQueue")
    SceneLog:CancelAll() --@DEL
end

--没有开始队列和还未完成队列都返回false
function PopupQueue:IsFinished()
    return self.isFinish
end

function PopupQueue:WorkingJobName()
    return popupForceQueuePriority[self.workIndex]
end
