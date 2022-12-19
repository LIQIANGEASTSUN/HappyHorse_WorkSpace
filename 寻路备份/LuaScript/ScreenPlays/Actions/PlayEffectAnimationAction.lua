
local PlayEffectAnimationAction = class(BaseFrameAction, "PlayEffectAnimationAction")

function PlayEffectAnimationAction:Create(params, finishCallback)
    local instance = PlayEffectAnimationAction.new(params, finishCallback)
    return instance
end

function PlayEffectAnimationAction:ctor(params, finishCallback)
    self.name = "PlayEffectAnimationAction"
    self.finishCallback = finishCallback
    self.started = false

    self.person = params.Person
    self.join = params.Join
    self.goName = params.Name
    self.animation = params.Animation
    self.animationType = params.AnimationType
    self.crossFadeTime = params.CrossFadeTime
end

function PlayEffectAnimationAction:Awake()
    local go
    if self.person then
        local host = GetPers(self.person)
        local parent = host.renderObj.transform:FindInDeep(self.join)
        go = parent.transform:Find(self.goName).gameObject
        console.assert(go, string.format("%s找不到", self.person)) --@DEL
    else
        go = App.scene.director:FindActor(self.goName)
        console.assert(go, string.format("%s找不到", self.goName)) --@DEL
    end

    if self.animation then
        local function finish()
            self.isFinished = true
        end
        if self.animationType == "spine" then
            GameUtil.PlaySpineAnimation(go, self.animation, false, finish)
        else
            local secs
            go:PlayAnim(self.animation, self.crossFadeTime or 0.2)
            secs = AnimatorEx.GetClipLength(go, self.animation)
            print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', secs) --@DEL
            WaitExtension.SetTimeout(finish, secs)
        end
    else
        self.isFinished = true
    end
end

function PlayEffectAnimationAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function PlayEffectAnimationAction:Reset()
    self.started = false
    self.isFinished = false
end

return PlayEffectAnimationAction