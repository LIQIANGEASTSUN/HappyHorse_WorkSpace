---@type AgentRender
local AgentRender = require "MainCity.Render.AgentRender"

local MonsterRender = class(AgentRender, "MonsterRender")

local CapsuleCollider = CS.UnityEngine.CapsuleCollider

function MonsterRender:ctor(resourceName)

end

function MonsterRender:ResetGameObject(gameObject)
    self.gameObject  = gameObject
    self.collider = self.gameObject:GetComponentInChildren(typeof(CapsuleCollider))

    self:GenRenderType(self.tId)
    self:SetName(self.name)
    self:SetClickable(self.clickable)
    if self.alpha then
        self:SetTransparency(self.alpha)
    end
    if self.isVisible ~= nil then
        local isVisible = self.isVisible
        self.isVisible = nil
        self:SetVisible(isVisible)
    end
    WaitExtension.InvokeDelay(
        function()
            self:InitDefaultAnimation(self.idleAnimaName)
        end
    )
    self:Trigger(true)
end



return MonsterRender