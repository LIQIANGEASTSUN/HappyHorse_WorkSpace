 local SpellFlyTo = class(BaseFrameAction, "SpellFlyTo")

function SpellFlyTo:Create(destPosition, secs, delay, leftOrRight, person, finishCallback)
    local instance = SpellFlyTo.new(destPosition, secs, delay, leftOrRight, person, finishCallback)
    return instance
end

function SpellFlyTo:ctor(destPosition, secs, delay, leftOrRight, person, finishCallback)
    self.name = "SpellFlyTo"
    self.finishCallback = finishCallback
    self.destPosition = destPosition
    self.started = false
    self.secs = secs or 1
    self.delay = delay or 0
    self.leftOrRight = leftOrRight or "R"
    self.person = person or "Player"
end

function SpellFlyTo:Awake()
    self.timestamp = Time.time
    self:InitSpellEffect()
end

function SpellFlyTo:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function SpellFlyTo:InitSpellEffect()

    local function startMove()

        Runtime.CSDestroy(self.spellEffect)
        self.spellEffect = nil

        self.afterSpellEffect = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/Other/E_player_magic_common_fly.prefab")

        self.afterSpellEffect.transform.position = GetPers(self.person):GetHandPosition(self.leftOrRight)

        CS.Bridge.Tweening.DoSpellMove(self.afterSpellEffect.transform, self.destPosition, self.secs, function()
            self:DestroySpellObject()
            self.isFinished = true

            --爆炸特效
            local effectBomb = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/Other/E_player_magic_common_bomb.prefab")
            effectBomb.transform.position = self.destPosition
            WaitExtension.SetTimeout(function()
                Runtime.CSDestroy(effectBomb)
            end, 2)
        end)
    end

    local function onLoadFinish()
        local person = GetPers(self.person).renderObj
        self.spellEffect = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/Other/E_player_magic_common.prefab")
        self.spellEffect.transform:SetParent(person.transform:FindInDeep(string.gsub("Bip001 replace Hand", "replace", self.leftOrRight)), false)

        self.handEffect = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/Other/E_player_magic_common_inhand.prefab")
        self.handEffect.transform:SetParent(person.transform:FindInDeep(string.gsub("Bip001 replace Finger2", "replace", self.leftOrRight)), false)
        if self.delay > 0 then
            WaitExtension.SetTimeout(startMove, self.delay)
        else
            startMove()
        end
    end
    local list = StringList()
    list:AddItem("Prefab/ScreenPlays/Other/E_player_magic_common.prefab")
    list:AddItem("Prefab/ScreenPlays/Other/E_player_magic_common_fly.prefab")
    list:AddItem("Prefab/ScreenPlays/Other/E_player_magic_common_bomb.prefab")
    list:AddItem("Prefab/ScreenPlays/Other/E_player_magic_common_inhand.prefab")
    AssetLoaderUtil.LoadAssets(list, onLoadFinish)
end

function SpellFlyTo:DestroySpellObject()
    if self.spellEffect then
        LuaHelper.ModifyParticleRate(self.spellEffect, 0)
        Runtime.CSDestroy(self.spellEffect, 0.5)
        self.spellEffect = nil
    end

    if self.afterSpellEffect then
        LuaHelper.ModifyParticleRate(self.afterSpellEffect, 0)
        Runtime.CSDestroy(self.afterSpellEffect, 0.5)
        self.afterSpellEffect = nil
    end

    if self.handEffect then
        LuaHelper.ModifyParticleRate(self.handEffect, 0)
        Runtime.CSDestroy(self.handEffect, 0.5)
        self.handEffect = nil
    end
end

function SpellFlyTo:Reset()
    self.started = false
    self.isFinished = false

    self:DestroySpellObject()
end

return SpellFlyTo