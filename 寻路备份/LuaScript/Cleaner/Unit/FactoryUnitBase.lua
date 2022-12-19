---@type BuildingLevelTemplateTool
local BuildingLevelTemplateTool = require "Cleaner.Factory.BuildingLevelTemplateTool"

--@type UnitBase
local UnitBase = require "Cleaner.Unit.Base.UnitBase"

---@type FactoryUnitBase
local FactoryUnitBase = class(UnitBase, "FactoryUnit")

function FactoryUnitBase:ctor(agent)
    self.agent = agent
    -- agetn 唯一 id
    self.id = agent:GetId()
    self.data = agent:GetData()
    self.level = self.data:GetLevel()
    self.key = AppServices.BuildingLevelTemplateTool:GetKey(self.data.meta.sn, self.level)

    self:SetUseUpdate(true)

    self.lastTime = 0
    self.currentStatus = ProductionStatus.None
end

function FactoryUnitBase:GetPosition()
    local go = self.agent:GetGameObject()
    if Runtime.CSValid(go) then
        return go.transform.position
    end
    return Vector3(0, 0, 0)
end

function FactoryUnitBase:LateUpdate()
    if Time.realtimeSinceStartup - self.lastTime < 1 then
        return
    end
    self.lastTime = Time.realtimeSinceStartup

    self:CheckFinish()
end

function FactoryUnitBase:FactoryClick(callback)
    self.productionData = self:GetProductionData()
    local status = AppServices.User:ProductionStatue(self.productionData)
    if status == ProductionStatus.Finish then
        AppServices.NetBuildingManager:SendTakeProduction(self.id)
        return
    end

    local position = self.agent:GetWorldPosition()
    MoveCameraLogic.Instance():MoveCameraToLook2(position, 1, 0, function()
        if callback then
            callback()
        else
            self:ClickMoveCameraFinish()
        end
    end)
end

function FactoryUnitBase:ClickMoveCameraFinish()
end

-- 点击了 Tips
function FactoryUnitBase:ProductionTipsClick()
    local data = self:GetProductionData()
    if not data then
        return
    end

    -- 生产时间结束
    local status = AppServices.User:ProductionStatue(data)
    if status == ProductionStatus.Doing then
    elseif status == ProductionStatus.Finish then
        AppServices.NetBuildingManager:SendTakeProduction(self.id)
        self:TakeProduction()
    end
end

function FactoryUnitBase:GetProductionData()
    local data = AppServices.User:GetProduction(self.id)
    return data
end

function FactoryUnitBase:CreateProductionData()
    local level = self.data:GetLevel()
    local sn = self.data.meta.sn
    local data = BuildingLevelTemplateTool:CreateProductionData(self.id, level, sn)
    AppServices.User:SetProduction(data)
    return data
end

-- 开始生产
function FactoryUnitBase:StartProduction()
    local data = self:GetProductionData()
    if not data then
        data = self:CreateProductionData()
    end
    data.status = ProductionStatus.Doing
end

-- 领取产物
function FactoryUnitBase:TakeProduction()
    local data = self:GetProductionData()
    if not data then
        return
    end

    AppServices.User:RemoveProduction(self.id)
    self:StateChangeToNone()
end

function FactoryUnitBase:CheckFinish()
    local data = self:GetProductionData()
    if not data then
        return
    end

    -- 生产时间结束
    local status = AppServices.User:ProductionStatue(data)
    if status == self.currentStatus then
        return
    end

    self.currentStatus = status
    if status == ProductionStatus.None then
        self:StateChangeToNone()
    elseif status == ProductionStatus.Doing then
        self:StateChangeToDoing()
    elseif status == ProductionStatus.Finish then
        self:StateChangeToFinish()
    end
end

function FactoryUnitBase:StateChangeToNone()

end

function FactoryUnitBase:StateChangeToDoing()

end

function FactoryUnitBase:StateChangeToFinish()
    local data = self:GetProductionData()
    if not data then
        self:CreateProductionData()
    end
end

function FactoryUnitBase:Remove()
end

return FactoryUnitBase