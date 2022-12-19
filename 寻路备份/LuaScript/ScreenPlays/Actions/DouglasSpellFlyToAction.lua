local DouglasSpellFlyToAction = class(BaseFrameAction, "DouglasSpellFlyToAction")

function DouglasSpellFlyToAction:Create(destPosition, secs, delay, leftOrRight, person, finishCallback)
    local instance = DouglasSpellFlyToAction.new(destPosition, secs, delay, leftOrRight, person, finishCallback)
    return instance
end

function DouglasSpellFlyToAction:ctor(destPosition, secs, delay, leftOrRight, person, finishCallback)
    print(leftOrRight) --@DEL
    self.name = "DouglasSpellFlyToAction"
    self.finishCallback = finishCallback
    self.destPosition = destPosition
    self.started = false
    self.secs = secs or 1
    self.delay = delay or 0
    self.leftOrRight = leftOrRight or "R"
    self.person = person or "Player"
end

function DouglasSpellFlyToAction:Awake()
    self.timestamp = Time.time
    self:InitSpellEffect()
end

function DouglasSpellFlyToAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function DouglasSpellFlyToAction:InitSpellEffect()

    local function startMove()
        self.afterSpellEffect = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/Other/E_Douglas_magic_common_fly.prefab")

        self.afterSpellEffect.transform.position = GetPers(self.person):GetHandPosition(self.leftOrRight)
        CS.Bridge.Tweening.DoSpellMove(self.afterSpellEffect.transform, self.destPosition, self.secs, function()
            self:DestroySpellObject()
            self.isFinished = true
        end)
    end

    local function onLoadFinish()
        if self.delay > 0 then
            WaitExtension.SetTimeout(startMove, self.delay)
        else
            startMove()
        end
    end
    local list = StringList()
    list:AddItem("Prefab/ScreenPlays/Other/E_Douglas_magic_common_fly.prefab")
    AssetLoaderUtil.LoadAssets(list, onLoadFinish)
end

function DouglasSpellFlyToAction:DestroySpellObject()
    if self.afterSpellEffect then
        LuaHelper.ModifyParticleRate(self.afterSpellEffect, 0)
        Runtime.CSDestroy(self.afterSpellEffect, 0.5)
        self.afterSpellEffect = nil
    end
end

function DouglasSpellFlyToAction:Reset()
    self.started = false
    self.isFinished = false

    self:DestroySpellObject()
end

return DouglasSpellFlyToAction