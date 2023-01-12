local RemoveEffectAction = class(BaseFrameAction, "RemoveEffectAction")

function RemoveEffectAction:Create(params, finishCallback)
    local instance = RemoveEffectAction.new(params, finishCallback)
    return instance
end

function RemoveEffectAction:ctor(params, finishCallback)
    self.name           = "RemoveEffectAction"
    self.finishCallback = finishCallback
    self.started        = false

    self.person         = params.Person
    self.goName         = params.Name
    self.isParticle     = params.IsParticle
    self.animation     = params.Animation
    self.animationType = params.AnimationType
end

function RemoveEffectAction:Awake()
    local goToDelete
    if self.person then
        local host = GetPers(self.person)
        console.assert(host, (self.person or "") .. "找不到！！！！！！！！！！！！！！！！！！") --@DEL
        goToDelete = host.renderObj.transform:FindInDeep(self.goName)
    else
        goToDelete = App.scene.director:FindActor(self.goName)
    end
    if RuntimeContext.VERSION_DEVELOPMENT then
        local strName = string.format("RemoveEffect  Person = %s, Name = %s", tostring(self.person), tostring(self.goName))
        console.assert(goToDelete ~= nil, strName .. " not found") --@DEL
    end
    if goToDelete then
        if self.isParticle then
            LuaHelper.ModifyParticleRate(goToDelete.gameObject, 0)
            Runtime.CSDestroy(goToDelete, 0.5)
            self.isFinished = true
        else
            local function finish()
                Runtime.CSDestroy(goToDelete.gameObject)
                goToDelete = nil
                self.isFinished = true
            end
            if self.animationType == 'spine' then
                GameUtil.PlaySpineAnimation(goToDelete, self.animation, false, finish)
            elseif self.animationType == 'animator' then
                goToDelete:PlayAnim(self.animation)
                WaitExtension.SetTimeout(finish, AnimatorEx.GetClipLength(goToDelete, self.animation))
            else
                finish()
            end
        end
    else
        self.isFinished = true
    end
end

function RemoveEffectAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function RemoveEffectAction:Reset()
    self.started    = false
    self.isFinished = false
end

return RemoveEffectAction