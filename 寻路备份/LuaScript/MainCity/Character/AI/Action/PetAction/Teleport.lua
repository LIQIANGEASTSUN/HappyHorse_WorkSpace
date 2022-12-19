local BaseAction = require "MainCity.Character.AI.Action.PetAction.BaseAction"

---@class Teleport : BasePetAction
local Teleport = class(BaseAction)
function Teleport:OnEnter(moveTo)
    BaseAction.OnEnter(self)
    self.moveToPos = moveTo

    self.render = self.brain.body.renderObj:GetComponentInChildren(typeof(SkinnedMeshRenderer))
    self:FadeOut()
end

function Teleport:FadeIn()
    local tarPos
    if self.moveToPos then
        tarPos = self.moveToPos
    else
        tarPos = self:GetTargetCurPos()
        local selfPos = self:GetPosition()
        local back = (selfPos - tarPos).normalized
        tarPos = tarPos + back * 0.45
    end
    self:SetPosition(tarPos)
    self:TweenAlpha(
        1,
        function()
            if not self.active then
                return
            end
            self.brain:ChangeAction("Idle", true)
        end
    )
end
function Teleport:FadeOut()
    self:TweenAlpha(
        0,
        function()
            if not self.active then
                return
            end
            self:FadeIn()
        end
    )
end

function Teleport:TweenAlpha(toValue, callback)
    local mat = self.render.material
    GameUtil.SetShader(mat, "HomeLand/FbxTransparency")
    local from = mat:GetFloat("_Alpha")
    local tween =
        LuaHelper.FloatSmooth(
        from,
        toValue,
        0.5,
        function(value)
            if not self.active then
                return
            end
            mat:SetFloat("_Alpha", value)
        end
    )
    tween.onComplete = callback
end

function Teleport:OnExit()
    BaseAction.OnExit(self)

    if Runtime.CSValid(self.render) then
        local mat = self.render.material
        GameUtil.SetShader(mat, "HomeLand/FbxTransparency")
        mat:SetFloat("_Alpha", 1)
    end
end

return Teleport
