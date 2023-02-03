---@type FoodFactoryUnit
local FoodFactoryUnit = require "Cleaner.Unit.FoodFactoryUnit"

---@type BuildUpLevelUnit
local BuildUpLevelUnit = require "Cleaner.Unit.BuildUpLevelUnit"

---@type NormalAgent
local NormalAgent = require("MainCity.Agent.NormalAgent")
---@class FoodFactoryAgent:NormalAgent 探索船
local FoodFactoryAgent = class(NormalAgent, "FoodFactoryAgent")

-- 食品工厂 Agent
function FoodFactoryAgent:ctor(id, data)
    self.data = data
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

    local factoryUnit = FoodFactoryUnit.new(self)
    self:AddUnit(factoryUnit)

    -- local buildUpLevelUnit = BuildUpLevelUnit.new(self)
    -- self:AddUnit(buildUpLevelUnit)
end

-- 处理点击
function FoodFactoryAgent:ProcessClick()
    local state = self:GetState()

    if state == CleanState.cleared then
        local region = self:GetRegion()
        local factoryUnit = self:GetUnit(UnitType.FoodFactoryUnit)
        if region and region:IsLinked() then
            if factoryUnit then
                return factoryUnit:FactoryClick()
            else
                console.error("factoryUnit is nil:")
                return
            end
        else
            local message = Runtime.Translate("tip_islandBuildingLock")
            local position = self:GetAnchorPosition()
            AppServices.SceneTextTip:Show(message, position)
        end
    end
end

function FoodFactoryAgent:ShowUpLevelPanel()
    self:ProcessClick()
end

-- 开始拖拽
-- AgentRender:OnEnterEditMode()
-- 在return true 之前加你隐藏 Tips

-- 退出拖拽
-- ExitEditMode

function FoodFactoryAgent:Destroy()
    NormalAgent.Destroy(self)
end

return FoodFactoryAgent
