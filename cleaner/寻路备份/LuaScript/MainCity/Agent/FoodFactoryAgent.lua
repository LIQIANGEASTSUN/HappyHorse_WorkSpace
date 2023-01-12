local FoodFactoryUnit = require "Cleaner.Unit.FoodFactoryUnit"

---@type NormalAgent
local NormalAgent = require("MainCity.Agent.NormalAgent")
---@class FoodFactoryAgent:NormalAgent 探索船
local FoodFactoryAgent = class(NormalAgent, "FoodFactoryAgent")

-- 食品工厂 Agent
function FoodFactoryAgent:ctor(id, data)
    self.data = data
    self.factoryUnit = nil
end

function FoodFactoryAgent:InitRender(callback)
    NormalAgent.InitRender(self, callback)
    self.render:AddInstantiateListener(
        function(result)
            self:RenderInstantiateCallBack(result)
        end
    )
end

function FoodFactoryAgent:RenderInstantiateCallBack(result)
    if not result then
        return
    end

    self.factoryUnit = FoodFactoryUnit.new(self)
    AppServices.UnitManager:AddUnit(self.factoryUnit)
end

-- 处理点击
function FoodFactoryAgent:ProcessClick()
    NormalAgent.ProcessClick(self)
    local state = self:GetState()

    if state == CleanState.cleared then
        --TODO  障碍物完全清除后点击仍需显示一些东西
        --local arguments = {DMapObj = 建筑数据}
        self.factoryUnit:FactoryClick()
    end
end

-- 开始拖拽
-- AgentRender:OnEnterEditMode()
-- 在return true 之前加你隐藏 Tips

-- 退出拖拽
-- ExitEditMode

function FoodFactoryAgent:GetFactoryUnit()
    return self.factoryUnit
end

function FoodFactoryAgent:Destroy()
    NormalAgent.Destroy(self)

    AppServices.UnitManager:RemoveUnit(self.factoryUnit)
    self.factoryUnit = nil
end

return FoodFactoryAgent