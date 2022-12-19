---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffRemoveBase
local BuffRemoveBase = require "Cleaner.Fight.Buff.BuffRemove.Base.BuffRemoveBase"

---@class BuffRemoveTriggerNumber
local BuffRemoveTriggerNumber = class(BuffRemoveBase, "BuffRemoveTriggerNumber")

function BuffRemoveTriggerNumber:ctor()
    self.removeType = BuffInfo.RemoveType.TriggerNumber

    self:Init()
end

function BuffRemoveTriggerNumber:Init()
    local buffConfig = self.buff:GetBuffConfig()
    self.triggerMax = buffConfig.removeValue
    self.triggerNumaber = 0
end

function BuffRemoveTriggerNumber:DoAction()
    self.triggerNumaber = self.triggerNumaber + 1
    if self.triggerMax > self.triggerNumaber then
        return
    end

    self.buff:BuffNeedRemove()
end

return BuffRemoveTriggerNumber