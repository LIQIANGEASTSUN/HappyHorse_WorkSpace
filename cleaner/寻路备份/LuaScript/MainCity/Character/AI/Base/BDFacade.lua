require("MainCity.Character.AI.Base.BDDefine")
require("MainCity.Character.AI.Base.BDActionBase")
require("MainCity.Character.AI.Base.BDConditional")
local BDUtil = require("MainCity.Character.AI.Base.BDUtil")
BDFacade = {}
BDFacade.updateInterval = 0.2
local l_BDTree2EntityMap = {}
local l_BDTreeActionMap = {}
local l_BDTreeBlackboradMap = {}
local l_AIEnable = true

App:addScreenPlayActivityListener(
    function(active)
        -- if App.screenPlayActive then
        --     BDFacade.SetAIEnable(false)
        -- end
        BDFacade.SetAIEnable(not App.screenPlayActive)
    end
)

function BDFacade.SetAIEnable(enable, checkTaskMute)
    if enable and checkTaskMute then
        enable = not BDUtil.IsLastFinishedTaskMuteAI()
    end
    if l_AIEnable == enable then
        return
    end
    l_AIEnable = enable
    if enable then
        BDFacade.ResumeAI()
    else
        BDFacade.PauseAI()
    end
end

function BDFacade.PauseAI()
    for _, v in pairs(l_BDTree2EntityMap) do
        v:SetActive(false)
    end
end

function BDFacade.ResumeAI()
    for _, v in pairs(l_BDTree2EntityMap) do
        v:SetActive(true)
    end
end

function BDFacade.IsAIEnable()
    return l_AIEnable == true
end

-- Build relationship between ai entity  and behavior tree instance
-- @param Charater entity
-- @param bdTree BehaviorTree Component
function BDFacade.RegisterAIEntity(entity, bdTree)
    if not entity or not bdTree then
        return
    end
    l_BDTree2EntityMap[bdTree] = entity

    if not l_BDTreeActionMap[bdTree] then
        l_BDTreeActionMap[bdTree] = {}
    end

    if not l_BDTreeBlackboradMap[bdTree] then
        l_BDTreeBlackboradMap[bdTree] = {}
    end
    if not l_AIEnable then
        entity:SetActive(false)
    end
end

function BDFacade.UnRegisterAIEntity(entity, bdTree)
    if not bdTree then
        return
    end

    if l_BDTree2EntityMap[bdTree] then
        l_BDTree2EntityMap[bdTree] = nil
    end

    local tasks = l_BDTreeActionMap[bdTree]
    if tasks then
        for _, action in pairs(tasks) do
            action:OnDestroy()
        end
        l_BDTreeActionMap[bdTree] = nil
    end

    if l_BDTreeBlackboradMap[bdTree] then
        l_BDTreeBlackboradMap[bdTree] = nil
    end
end

function BDFacade.SetBDTreeBlackboardValue(bdTree, key, val)
    if not bdTree or not key or not val then
        return
    end

    local blackboard = l_BDTreeBlackboradMap[bdTree]
    if blackboard then
        blackboard[key] = val
    end
end

function BDFacade.GetBDTreeByEntity(entity)
    if not entity then
        return
    end
    for k, v in pairs(l_BDTree2EntityMap) do
        if v == entity then
            return k
        end
    end
    return nil
end

function BDFacade.GetBlackboard(bdTree)
    return l_BDTreeBlackboradMap[bdTree]
end
------------------------------ action execute function --------------------------
local function l_createLuaAction(task, btTree, entity)
    local cls = require("MainCity.Character.AI.Action." .. task.actionName)
    return cls.new(task, btTree, entity)
end

local function l_getLuaAction(task)
    local bdTree = task.Owner
    if l_BDTreeActionMap[bdTree] then
        return l_BDTreeActionMap[bdTree][task.ID]
    end
    return nil
end

function BDFacade.actionAwake(task)
    if not task.actionName then
        task.actionName = "TestAIAction"
    end
    local bdTree = task.Owner
    local entity = l_BDTree2EntityMap[bdTree]
    if not bdTree or not entity then
        return
    end
    --construct a lua action by action name  corresponding the  cs action object
    --and add in bdtree's actions table
    local action = l_createLuaAction(task, bdTree, entity)
    local treeActions = l_BDTreeActionMap[bdTree]
    treeActions[task.ID] = action
    action:SetBlackboard(l_BDTreeBlackboradMap[bdTree])
end

function BDFacade.actionStart(task)
    local action = l_getLuaAction(task)
    if action then
        action:OnStart()
    end
end

function BDFacade.actionOnUpdate(task)
    local action = l_getLuaAction(task)
    if action then
        return action:OnUpdate()
    end
    return BDTaskStatus.Failure
end

function BDFacade.acitonLateUpdate(task)
    local action = l_getLuaAction(task)
    if action then
        return action:OnLateUpdate()
    end
end

function BDFacade.acitonFixedUpdate(task)
    local action = l_getLuaAction(task)
    if action then
        return action:OnFixedUpdate()
    end
end

function BDFacade.actionOnEnd(task)
    local action = l_getLuaAction(task)
    if action then
        action:OnEnd()
    end
end

function BDFacade.actionOnPaused(task, paused)
    local action = l_getLuaAction(task)
    if action then
        action:OnPause(paused)
    end
end

function BDFacade.actionOnConditionalAbort(task)
    local action = l_getLuaAction(task)
    if action then
        action:OnConditionalAbort()
    end
end

function BDFacade.actionGetPriority(task)
    local action = l_getLuaAction(task)
    if action then
        return action:GetPriority()
    end

    return 0
end

function BDFacade.actionGetUtility(task)
    local action = l_getLuaAction(task)
    if action then
        return action:GetUtility()
    end
    return 0
end

function BDFacade.actionOnBehaviorRestart(task)
    local action = l_getLuaAction(task)
    if action then
        action:OnBehaviorRestart()
    end
end

function BDFacade.actionOnBehaviorComplete(task)
    local action = l_getLuaAction(task)
    if action then
        action:OnBehaviorComplete()
    end
end

function BDFacade.actionOnReset(task)
    local action = l_getLuaAction(task)
    if action then
        action:OnReset()
    end
end

------------------------------ conditional execute function --------------------------
function BDFacade.conditionalOnUpdate(task)
    local name = task.conditionName
    local bdTree = task.Owner
    local entity = l_BDTree2EntityMap[bdTree]
    local blackborad = l_BDTreeBlackboradMap[bdTree]
    if bdTree and entity then
        return BDConditional.If(name, entity, bdTree, blackborad, task)
    end
    return false
end
