local BaseAction = require "MainCity.Character.AI.Action.PetAction.BaseAction"
---@class Clicked:BasePetAction
local Clicked = class(BaseAction)
local anims = {
    "happy",
    "touch1",
    "touch2"
}
function Clicked:OnEnter()
    BaseAction.OnEnter(self)
    self.ts = Time.time
    local index = math.random(#anims)
    local animation = anims[index]
    self.duration = self:GetAnimDuration(animation)
    self:PlayAnimation(animation)
end

function Clicked:OnTick()
    if Time.time - self.ts >= self.duration then
        self.brain:ChangeAction("Idle")
    end
end

return Clicked
