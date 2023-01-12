local DecorationFactoryUnit = require "Cleaner.Unit.DecorationFactoryUnit"

---@type NormalAgent
local NormalAgent = require("MainCity.Agent.NormalAgent")
---@class DecorationFactoryAgent:NormalAgent 装饰品工厂
local DecorationFactoryAgent = class(NormalAgent, "DecorationFactoryAgent")

-- 探索船 Agent
function DecorationFactoryAgent:ctor(id, data)
    self.data = data
    self.factoryUnit = nil
end

function DecorationFactoryAgent:InitRender(callback)
    NormalAgent.InitRender(self, callback)
    self.render:AddInstantiateListener(
        function(result)
            self:RenderInstantiateCallBack(result)
        end
    )
end

function DecorationFactoryAgent:RenderInstantiateCallBack(result)
    if not result then
        return
    end

    local production = AppServices.User:GetProduction(self:GetId())
    SceneServices.DecorationFactory:InitWithResponse(self:GetId(), production)
    -- self:NotifyProduction(true)

    self.factoryUnit = DecorationFactoryUnit.new(self)
    AppServices.UnitManager:AddUnit(self.factoryUnit)
end

-- 处理点击
function DecorationFactoryAgent:ProcessClick()
    NormalAgent.ProcessClick(self)
    local state = self:GetState()

    if state == CleanState.cleared then
        --TODO  障碍物完全清除后点击仍需显示一些东西
        --local arguments = {DMapObj = 建筑数据}
        console.lzl("test click")
        self.factoryUnit:FactoryClick(function()
            SceneServices.DecorationFactory:ShowPanel()
        end)
    end
end

function DecorationFactoryAgent:GetFactoryUnit()
    return self.factoryUnit
end

function DecorationFactoryAgent:Destroy()
    NormalAgent.Destroy(self)

    AppServices.UnitManager:RemoveUnit(self.factoryUnit)
    self.factoryUnit = nil
end

return DecorationFactoryAgent