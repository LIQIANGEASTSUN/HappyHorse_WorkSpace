---@class PlayerBigOrLittleDropAction:BaseFrameAction
local PlayerBigOrLittleDropAction = class(BaseFrameAction, "PlayerBigOrLittleDropAction")

function PlayerBigOrLittleDropAction:Create(isLittle, idleTime, finishCallback)
    local instance = PlayerBigOrLittleDropAction.new(isLittle, idleTime, finishCallback)
    return instance
end

function PlayerBigOrLittleDropAction:ctor(isLittle, idleTime, finishCallback)
    self.name = "PlayerBigOrLittleDropAction"
    self.isLittle = isLittle
    self.idleTime = idleTime or 1
    self.finishCallback = finishCallback
    self.started = false
end

function PlayerBigOrLittleDropAction:Awake()
    self.timestamp = Time.time
    self:InitEffects()
end

function PlayerBigOrLittleDropAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function PlayerBigOrLittleDropAction:InitEffects()
    local function onFinish()
        self.isFinished = true
    end
    local function RemoveEffects()
        local person = GetPers("Player")
        if person then
            local parentTrans = person.renderObj.transform
            local effect = parentTrans:Find("E_player_magic_float_idle")
            if effect then
                Runtime.CSDestroy(effect.gameObject)
            end
        end
    end

    if self.isLittle then
        local sequence = Sequence:Create(onFinish)
        sequence:Append(CallFunc:Create(RemoveEffects))
        sequence:Append(Actions.PlayAnimationAction:Create("Player", "magic_float_little_drop"))
        sequence:Append(Actions.PlayAnimationAction:Create("Player", "magic_float_little_drop_end"))
        sequence:Append(Actions.PlayAnimationAction:Create("Player", "magic_float_little_drop_Idle"))
        sequence:Append(Actions.DelayS:Create(self.idleTime or 1))
        sequence:Append(Actions.PlayAnimationAction:Create("Player", "magic_float_little_drop_getup"))
        App.scene.director:AppendFrameAction(sequence)
    else

        local sequence = Sequence:Create(onFinish)
        sequence:Append(CallFunc:Create(RemoveEffects))
        sequence:Append(Actions.PlayAnimationAction:Create("Player", "magic_float_big_drop"))
        sequence:Append(Actions.PlayAnimationAction:Create("Player", "magic_float_big_drop_end"))
        sequence:Append(Actions.PlayAnimationAction:Create("Player", "magic_float_big_drop_Idle"))
        sequence:Append(Actions.DelayS:Create(self.idleTime or 1))
        sequence:Append(Actions.PlayAnimationAction:Create("Player", "magic_float_big_drop_getup"))
        App.scene.director:AppendFrameAction(sequence)
    end
end

function PlayerBigOrLittleDropAction:DestroyEffects()
    Runtime.CSDestroy(self.effect1)
    Runtime.CSDestroy(self.effect2)
    self.effect1 = nil
    self.effect2 = nil
end

function PlayerBigOrLittleDropAction:Reset()
    self.started = false
    self.isFinished = false

    self:DestroyEffects()
end

return PlayerBigOrLittleDropAction