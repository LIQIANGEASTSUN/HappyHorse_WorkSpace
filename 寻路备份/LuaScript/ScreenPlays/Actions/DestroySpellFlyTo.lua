local DestroySpellFlyTo = class(BaseFrameAction, "DestroySpellFlyTo")

function DestroySpellFlyTo:Create(destPosition, secs, delay, leftOrRight, finishCallback)
    local instance = DestroySpellFlyTo.new(destPosition, secs, delay, leftOrRight, finishCallback)
    return instance
end

function DestroySpellFlyTo:ctor(destPosition, secs, delay, leftOrRight, finishCallback)
    print(leftOrRight) --@DEL
    self.name = "DestroySpellFlyTo"
    self.finishCallback = finishCallback
    self.destPosition = destPosition
    self.started = false
    self.secs = secs or 1
    self.delay = delay or 0
    self.leftOrRight = leftOrRight or "R"
end

function DestroySpellFlyTo:Awake()
    self.timestamp = Time.time
    self:InitSpellEffect()
end

function DestroySpellFlyTo:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function DestroySpellFlyTo:InitSpellEffect()

    local function startMove()
        self.spellEffect = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/Other/E_player_magic_common_fly.prefab")

        self.spellEffect.transform:SetParent(nil, false)
        self.spellEffect.transform.position = GetPers("Player"):GetHandPosition(self.leftOrRight)
        CS.Bridge.Tweening.DoSpellMove(self.spellEffect.transform, self.destPosition, self.secs, function()
            self.isFinished = true
            self:DestroySpellObject()
        end)
    end

    local function onLoadFinish()
        local person = GetPers("Player").renderObj
        self.playerHandTransform = person.transform:FindInDeep("Bip001 R Forearm")

        self.handEffect = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/Other/E_player_magic_rubish_xvli.prefab")
        self.handEffect.transform:SetParent(person.transform:FindInDeep("Point001"), false)
        --self.handEffect.transform.position = person.transform.position
        print(self.delay) --@DEL
        if self.delay > 0 then
            WaitExtension.SetTimeout(startMove, self.delay)
        else
            startMove()
        end
    end
    local list = StringList()
    list:AddItem("Prefab/ScreenPlays/Other/E_player_magic_common_fly.prefab")
    list:AddItem("Prefab/ScreenPlays/Other/E_player_magic_rubish_xvli.prefab")
    list:AddItem("Prefab/ScreenPlays/Other/E_player_magic_common_bomb.prefab")
    AssetLoaderUtil.LoadAssets(list, onLoadFinish)
end

function DestroySpellFlyTo:DestroySpellObject()
    if self.spellEffect then
        LuaHelper.ModifyParticleRate(self.spellEffect, 0)
        Runtime.CSDestroy(self.spellEffect, 0.5)
        self.spellEffect = nil
    end
    if self.handEffect then
        LuaHelper.ModifyParticleRate(self.handEffect, 0)
        Runtime.CSDestroy(self.handEffect, 0.5)
        self.handEffect = nil
    end

    local bombEffect = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/Other/E_player_magic_common_bomb.prefab")
    console.assert(bombEffect)
    bombEffect:SetPosition(self.destPosition)
    WaitExtension.SetTimeout(function()
        Runtime.CSDestroy(bombEffect)
        bombEffect = nil
    end, 2)
end

function DestroySpellFlyTo:Reset()
    self.started = false
    self.isFinished = false

    self:DestroySpellObject()
end

return DestroySpellFlyTo