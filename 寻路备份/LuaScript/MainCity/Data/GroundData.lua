local SuperCls = require "MainCity.Data.AgentData"
---@class GroundData:AgentData
local GroundData = class(SuperCls, "GroundData")

function GroundData:GetCleanCosted()
    local progress = self.extraData and self.extraData.progress and self.extraData.progress[1]
    return (progress and progress.value) or 0
end

function GroundData:AddCleanCosted(key, value)
    if not self.extraData then
        self.extraData = {}
    end
    if not self.extraData.progress then
        local progress = {key = key, value = value}
        self.extraData.progress = {progress}
        return
    end
    local orgProgress = self.extraData.progress[1]
    orgProgress.value = orgProgress.value + value
end

function GroundData:InitExtraData(data)
    self.extraData = data
    local id, cost = self:GetCurrentCost()
    if 0 >= cost then
        self:SetState(CleanState.cleared)
    end
end

function GroundData:GetMetaCost()
    return self.meta.consume
end

function GroundData:GetCurrentCost()
    local consume = self:GetMetaCost()
    local need = consume[1]
    if not need or #need ~= 2 then
        return 0, 0
    end
    local costed = self:GetCleanCosted()
    local delta = need[2] - costed
    -- local discount = AppServices.DragonBuff:GetOffPercent()
    -- if delta ~= 0 and discount < 1 then
    --     delta = (need[2] - costed) * discount
    --     delta = math.max(delta, 1)
    --     delta = math.floor(delta)
    -- end
    return need[1], delta, need[2]
end

function GroundData:Clean(value)
    local id, cost = self:GetCurrentCost()
    if value >= cost then
        self:SetState(CleanState.cleared)
    end
    self:AddCleanCosted(id, value)
end

return GroundData
