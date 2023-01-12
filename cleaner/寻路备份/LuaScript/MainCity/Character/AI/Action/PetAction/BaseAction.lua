---@class BasePetAction
local BaseAction = class()

function BaseAction:ctor(brain)
    self.brain = brain
end

function BaseAction:OnEnter()
    self.active = true
    self:ResetTargetOrgPos()
    self:SetHeight()
end

function BaseAction:SetHeight()
    self.brain.body:SetHeight(1.9)
end
function BaseAction:GetHeight()
    return self.brain.body:GetHeight()
end

function BaseAction:OnTick()
end

function BaseAction:OnExit()
    self.active = false
end

function BaseAction:GetPosition()
    return self.brain.body:GetPosition()
end
function BaseAction:SetPosition(position)
    self.brain.body:SetPosition(position)
end

function BaseAction:GetAnimDuration(animName)
    return AnimatorEx.GetClipLength(self.brain.body.renderObj, animName)
end
function BaseAction:PlayAnimation(animName)
    self.brain.body:PlayAnimation(animName)
end

function BaseAction:GetTargetPlayer()
    if not self.orgPlayerPos then
        local player = CharacterManager.Instance():Get("Femaleplayer")
        self.followPlayer = player
    end
    return self.followPlayer
end

function BaseAction:ResetTargetOrgPos()
    self.orgPlayerPos = nil
    self:GetTargetOrgPos()
end
--记录目标原来位置
function BaseAction:GetTargetOrgPos()
    if not self.orgPlayerPos then
        local player = self:GetTargetPlayer()
        if player then
            local position = player:GetPosition()
            local height = self:GetHeight()
            self.orgPlayerPos = position:Flat(height)
        end
    end
    return self.orgPlayerPos
end
--获取目标当前位置
function BaseAction:GetTargetCurPos()
    local player = self:GetTargetPlayer()
    if player then
        local position = player:GetPosition()
        local height = self:GetHeight()
        return position:Flat(height)
    end
end

return BaseAction
