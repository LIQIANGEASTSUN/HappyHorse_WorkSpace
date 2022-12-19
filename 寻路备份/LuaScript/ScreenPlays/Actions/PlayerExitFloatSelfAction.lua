---@class PlayerExitFloatSelfAction:BaseFrameAction
local PlayerExitFloatSelfAction = class(BaseFrameAction, "PlayerExitFloatSelfAction")

function PlayerExitFloatSelfAction:Create(finishCallback)
    local instance = PlayerExitFloatSelfAction.new(finishCallback)
    return instance
end

function PlayerExitFloatSelfAction:ctor(finishCallback)
    self.name = "PlayerExitFloatSelfAction"
    self.started = false
end

function PlayerExitFloatSelfAction:Awake()
    self.timestamp = Time.time
    self:InitEffects()
end

function PlayerExitFloatSelfAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function PlayerExitFloatSelfAction:InitEffects()
    local function onFinish()
        local person = GetPers("Player")
        if person then
            local parentTrans = person.renderObj.transform
            local effect = parentTrans:Find("E_player_magic_float_idle")
            if effect then
                Runtime.CSDestroy(effect.gameObject)
            else
                print('1111111111111111111111111111111111111111111') --@DEL
            end
        end
        self.isFinished = true
    end
    local sequence = Sequence:Create(onFinish)
    sequence:Append(Actions.PlayAnimationAction:Create("Player", "magic_float_fall"))
    sequence:Append(Actions.PlayAnimationAction:Create("Player", "magic_float_fall_end"))
    App.scene.director:AppendFrameAction(sequence)
end

function PlayerExitFloatSelfAction:DestroyEffects()
    Runtime.CSDestroy(self.effect1)
    Runtime.CSDestroy(self.effect2)
    self.effect1 = nil
    self.effect2 = nil
end

function PlayerExitFloatSelfAction:Reset()
    self.started = false
    self.isFinished = false

    self:DestroyEffects()
end

return PlayerExitFloatSelfAction