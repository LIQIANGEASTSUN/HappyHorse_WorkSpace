local BaseAction = require "MainCity.Character.AI.Action.PetAction.BaseAction"
---@class StandIdle:BasePetAction
local StandIdle = class(BaseAction)

local randomMoveMinDuration = 5.0
local randomMoveMaxDuration = 8.0

--local animEnter = "land"
local animation = "standIdle"
local animExit = "takeoff"
local animWalk = "walk"

local randomAnims = {
    "rest",
    "rest1",
    "rest2"
}

local nextPosDuration  --下一个随机动作间隔时长
local playerMoveThreshold = 3 --转成追踪人物移动距离阈值
-- local chestCheckDis = 0.5 --探测宝箱距离(宝箱距人物)
-- local chestAlertDis = 2 --警戒探测宝箱距离(宝箱距人物)
local sleepyDuration = 25

function StandIdle:OnEnter(check)
    BaseAction.OnEnter(self)
    self.randPosTs = Time.time --记录上次随机位置时刻
    self.sleepyTs = Time.time --记录目标停留时刻
    nextPosDuration = Random.Range(randomMoveMinDuration, randomMoveMaxDuration)
    self:PlayAnimation(animation)
    self.check = check --标记刚进入idle状态后是否立刻检测
end

function StandIdle:SetHeight()
    self.brain.body:SetHeight(0)
end

function StandIdle:OnTargetMoved()
    local selfPos = self:GetPosition()
    local curPos = self:GetTargetCurPos()
    --local orgPos = self:GetTargetOrgPos()

    self.sleepyTs = Time.time
    if selfPos:FlatDistance(curPos) >= playerMoveThreshold then
        return self:ChangeTo("MoveTo")
    else
        -- local agent, dis = App.scene.objectManager:GetAgentByObstacleType(ObstacleType.box, curPos:Flat())
        -- if agent and dis < chestAlertDis then
        --     local selfPos = self:GetPosition()
        --     local agentPos = agent:GetWorldPosition()
        --     agentPos = agentPos:Flat(selfPos.y)
        --     if selfPos:FlatDistance(agentPos) < chestCheckDis then
        --         return self:ChangeTo("Research", agentPos)
        --     end

        --     local dir = selfPos - agentPos
        --     return self:ChangeTo("MoveTo", agentPos + dir.normalized * chestCheckDis * 0.6)
        -- end
    end
    self:ResetTargetOrgPos()
end

local grid_radius_min = 2
local grid_radius_max = 2
function StandIdle:GetNewPos()
    local position = self:GetTargetCurPos()

    local map = App.scene.mapManager
    local x, z = map:ToLocal(position)

    local grids = {}

    for i = -grid_radius_max, grid_radius_max do
        for j = -grid_radius_max, grid_radius_max do
            if math.abs(i) >= grid_radius_min or math.abs(j) >= grid_radius_min then
                local _x, _z = x + i, z + j
                local psb = map:IsPassable(x + i, z + j)
                if psb then
                    local state = map:GetState(x + i, z + j)
                    if state == CleanState.cleared then
                        local occupied = map:HasObjects(_x, _z)
                        if not occupied then
                            table.insert(grids, {_x, _z})
                        end
                    end
                end
            end
        end
    end

    if #grids > 0 then
        local index = math.random(#grids)
        local grid = grids[index]
        return map:ToWorld(grid[1], grid[2])
    end
    return self:GetTargetCurPos()
end

---时间到了移动到下一个随机点
function StandIdle:MoveToNewPos()
    if self.flyTween then
        self.flyTween:Kill(false)
        self.flyTween = nil
    end

    nextPosDuration = Random.Range(randomMoveMinDuration, randomMoveMaxDuration)
    self:ResetTargetOrgPos()
    self:PlayAnimation(animWalk)
    local animName = randomAnims[math.random(#randomAnims)]
    self.randPosTs = Time.time + 15

    local height = self:GetHeight()
    local tarPos = self:GetNewPos()
    tarPos = tarPos:Flat(height)
    local trans = self.brain.body.transform
    local dir = trans.forward
    local wayPoints = {
        trans.position,
        trans.position + dir * 0.5,
        tarPos
    }
    local pathList = Vector3List()
    pathList:Add(wayPoints[1])
    pathList:Add(wayPoints[2])
    pathList:Add(wayPoints[3])

    local speed = 0.3
    self.flyTween =
        BPath.MoveToDirect(
        trans,
        pathList:ToArray(),
        speed,
        function()
            self.flyTween = nil
            self.randPosTs = Time.time + self:GetAnimDuration(animName)
            self:PlayAnimation(animName)
        end,
        nil
    )
end

function StandIdle:OnTick()
    if self.check then
        self.check = false
        return self:OnTargetMoved()
    end

    local curPos = self:GetTargetCurPos()
    local orgPos = self:GetTargetOrgPos()
    if curPos == orgPos then
        local selfPos = self:GetPosition()
        if selfPos:FlatDistance(curPos) > playerMoveThreshold then
            return self:ChangeTo("MoveTo")
        end

        if Time.time - self.sleepyTs >= sleepyDuration then
            return self:ChangeTo("Sleepy")
        end
        --玩家无移动时间超过N秒
        if Time.time - self.randPosTs > nextPosDuration then
            return self:MoveToNewPos()
        end
    else
        if self.changingTimer then
            return
        end
        return self:OnTargetMoved()
    end
end

function StandIdle:ChangeTo(state, params)
    if self.changingTimer then
        return
    end
    if state == "Sleepy" then
        return self.brain:ChangeAction(state, params)
    end
    local duration = self:GetAnimDuration(animExit)
    self:PlayAnimation(animExit)
    self.changingTimer =
        WaitExtension.SetTimeout(
        function()
            if not self.active then
                return
            end
            self.brain:ChangeAction(state, params)
        end,
        duration
    )
end

function StandIdle:OnExit()
    BaseAction.OnExit(self)
    if self.changingTimer then
        WaitExtension.CancelTimeout(self.changingTimer)
        self.changingTimer = nil
    end
    if self.flyTween then
        self.flyTween:Kill(false)
        self.flyTween = nil
    end
end

return StandIdle
