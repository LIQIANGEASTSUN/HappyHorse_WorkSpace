BDConditional = {}
local BDUtil = require("MainCity.Character.AI.Base.BDUtil")
local Conditions = {}
--[[
    @desc:  judge  behavior tree  condition
    --@name: condition  name
	--@aiEntity: current execute ai entity
	--@bdTree: current behavior tree
    --@blackboard: current behaivor tree blackboard
    --@csTask: cuccert c# task object
    @return:
]]
function BDConditional.If(name, aiEntity, bdTree, blackboard, csTask)
    local c_func = Conditions[name]
    if c_func and type(c_func == "function") then
        return c_func(aiEntity, bdTree, blackboard, csTask)
    end
    return false
end

---------------------contiditons---------------------------
--判断是否执行过出生AI
function Conditions.IsEntityBorn(entity, bdTree, blackboard)
    return blackboard["isBorn"] == 1
end

function Conditions.IsInPosition(aiEntity, bdTree, blackboard, csTask)
    local param = csTask.strParam1
    local value = table.deserialize(param)
    if not value then
        return false
    end
    local curPos = aiEntity:GetGameObject():GetPosition()
    curPos = curPos:Flat()
    if math.abs(curPos.x - value[1]) > 0.02 then
        return false
    end
    if math.abs(curPos.z - value[3]) > 0.02 then
        return false
    end
    return true
end

--- 比较全局Blackboard中的int值
---@param bdTree string 需要比较的key
---@param blackboard int 需要比较的目标int值
---@param csTask int 比较类型 0比较相等 -1小于目标值 1 大于目标值
function Conditions.CompareGlobalBlackboardInt(aiEntity, bdTree, blackboard, csTask)
    local key = csTask.strParam1
    local targetVal = csTask.intParam1
    local compareType = csTask.intParam2
    local val = BDFacade.GetGlobalBalckboardValue(key)
    if compareType == 1 then
        return val > targetVal
    elseif compareType == -1 then
        return val < targetVal
    else
        return val == targetVal
    end
end

--- 比较当前AI Enity Blackboard中的bool值
--- setParam1:需要比较的key
function Conditions.CompareBlackboardBool(aiEntity, bdTree, blackboard, csTask)
    local key = csTask.strParam1
    return blackboard[key] == true
end

--- 比较当前AI Enity Blackboard中的int值
--- strParam1:需要比较的key
--- intParam1:需要比较的目标int值
--- intParam2:比较类型 0比较相等 -1小于目标值 1 大于目标值
function Conditions.CompareBlackboardInt(aiEntity, bdTree, blackboard, csTask)
    local key = csTask.strParam1
    local targetVal = csTask.intParam1
    local compareType = csTask.intParam2
    local val = blackboard[key]
    if compareType == 1 then
        --print("Compare Key:",key,targetVal,"    ",val,val > targetVal) --@DEL
        return val > targetVal
    elseif compareType == -1 then
        return val < targetVal
    else
        return val == targetVal
    end
end

--判断角色动作组ID
function Conditions.CompareActionGroupId(aiEntity, bdTree, blackboard, csTask)
    local targetValue = csTask.intParam1
    return blackboard["IAGId"] == targetValue
end

--是否进入任务AI
function Conditions.CanEnterTaskAI(aiEntity, bdTree, blackboard, csTask)
    return BDUtil.LastFinisednTaskHasAI()
end
