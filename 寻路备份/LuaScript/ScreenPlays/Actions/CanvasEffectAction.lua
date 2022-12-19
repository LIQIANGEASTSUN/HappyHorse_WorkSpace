local CanvasEffectAction = class(BaseFrameAction, "CanvasEffectAction")

function CanvasEffectAction:Create(params, finishCallback)
    local instance = CanvasEffectAction.new(params, finishCallback)
    return instance
end

function CanvasEffectAction:ctor(params, finishCallback)
    self.name = "CanvasEffectAction"
    self.finishCallback = finishCallback

    self.started = false

    console.assert(params.Prefab, "Prefab 不能为空")
    console.assert(params.In, "In 不能为空")
    console.assert(params.Idle, "Idle 不能为空")
    console.assert(params.Out, "Out 不能为空")
    console.assert(params.Duration, "Duration 不能为空")
    console.assert(params.AnimationType, "AnimationType 不能为空")
    console.assert(params.IdleLoop ~= nil, "IdleLoop 不能为空")

    self.prefabPath = "Prefab/ScreenPlays/canvas_effect/" .. params.Prefab
    self.inAnimation = params.In
    self.idleAnimation = params.Idle
    self.outAnimation = params.Out
    self.duration = params.Duration
    self.animationType = params.AnimationType
    self.idleLoop = params.IdleLoop
end

function CanvasEffectAction:Awake()
    self.timestamp = Time.time

    App.dramaAssetManager:LoadAssets({self.prefabPath}, function()
        local go = BResource.InstantiateFromAssetName(self.prefabPath)
        --go.transform:SetParent(App.scene.canvas.transform, false)
        console.assert(go, string.format("%s无法创建物体", self.prefabPath))
        if self.animationType == "spine" then
            GameUtil.PlaySpineAnimation(go, self.inAnimation, false, function()
                GameUtil.PlaySpineAnimation(go, self.idleAnimation, self.idleLoop)
                WaitExtension.SetTimeout(function()
                    GameUtil.PlaySpineAnimation(go, self.outAnimation, false, function()
                        GameObject.Destroy(go)
                        self.isFinished = true
                    end)
                end, self.duration)

            end)
        else
            local inSecs = AnimatorEx.GetClipLength(go, self.inAnimation)
            go:PlayAnim(self.inAnimation)
            print('11111111111111 play in', inSecs) --@DEL
            WaitExtension.SetTimeout(function()
                go:PlayAnim(self.idleAnimation)
                WaitExtension.SetTimeout(function()
                    local outSecs = AnimatorEx.GetClipLength(go, self.outAnimation)
                    go:PlayAnim(self.outAnimation)
                    print('33333333333333 play out', outSecs) --@DEL
                    WaitExtension.SetTimeout(function()
                        GameObject.Destroy(go)
                        self.isFinished = true
                    end, outSecs)
                end, self.duration)
            end, inSecs)
        end
    end)
end

function CanvasEffectAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function CanvasEffectAction:Reset()
    self.started = false
    self.isFinished = false
end

return CanvasEffectAction