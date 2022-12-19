local FsmStateBase = require "Fsm.StateMachine.FsmStateBase"
local ChangeSceneAnimation = require "Game.Common.ChangeSceneAnimation"

---@class ShipStateBase
local ShipStateBase = class(FsmStateBase, "ShipStateBase")
-- 探索船状态基类

function ShipStateBase:ctor(entity)
    self.entity = entity
    self.stateType = 0
    self.activity = false
end

function ShipStateBase:SetEntity(entity)
    self.entity = entity
    self:SetCommonTransition()
end

function ShipStateBase:Init()

end

-- Player 碰撞到船
function ShipStateBase:TriggerPlayer()

end

-- 处理点击
function ShipStateBase:ProcessClick()

end

function ShipStateBase:SetEntityPosition(entity, playerPos)
    local x = Random.Range(-1, 1)
    local z = Random.Range(-1, 1)
    local pos = playerPos + Vector3(x, 0, z)
    entity:SetPosition(pos)
end

function ShipStateBase:StartSailing(finish)
    ChangeSceneAnimation.Instance():EnterCityIn(finish)
end

function ShipStateBase:EndSailing()
    ChangeSceneAnimation.Instance():PlayOut(nil)
end

--[[
function ShipStateBase:OnEnter()
end

function ShipStateBase:OnTick()
end

function ShipStateBase:OnExit()
end
--]]

return ShipStateBase