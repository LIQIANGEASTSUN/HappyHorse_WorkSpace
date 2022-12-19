---@class PlayerBeginFirstFloatAction:BaseFrameAction
local PlayerBeginFirstFloatAction = class(BaseFrameAction, "PlayerBeginFirstFloatAction")

function PlayerBeginFirstFloatAction:Create(finishCallback)
    local instance = PlayerBeginFirstFloatAction.new(finishCallback)
    return instance
end

function PlayerBeginFirstFloatAction:ctor(finishCallback)
    self.name = "PlayerBeginFirstFloatAction"
    self.started = false
end

function PlayerBeginFirstFloatAction:Awake()
    self.timestamp = Time.time
    self:InitEffects()
end

function PlayerBeginFirstFloatAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function PlayerBeginFirstFloatAction:InitEffects()


    local function onLoadFinish()
        self.effect1 = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/Other/E_player_magic1.prefab")
        self.effect2 = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/Other/E_player_magic2.prefab")
        self.floatIdleEffect = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/Other/E_player_magic_float_idle.prefab")
        self.floatIdleEffect.name = "E_player_magic_float_idle"

        local person = GetPers("Player")
        local parentTrans = person.renderObj.transform
        self.effect1.transform:SetParent(parentTrans, false)
        self.effect2.transform:SetParent(parentTrans, false)
        self.floatIdleEffect.transform:SetParent(parentTrans, false)
        local function onFinish()
            self:DestroyEffects()
            self.isFinished = true
        end
        local sequence = Sequence:Create(onFinish)
        sequence:Append(Actions.PlayAnimationAction:Create("Player", "magic_float"))
        --sequence:Append(PlayAnimationAction:Create("Player", "magic_float_first_rise_start"))
        sequence:Append(Actions.PlayAnimationAction:Create("Player", "magic_float_first_rise"))
        sequence:Append(Actions.PlayAnimationAction:Create("Player", "magic_float_first_Idle"))
        App.scene.director:AppendFrameAction(sequence)
    end

    local list = StringList()
    list:AddItem("Prefab/ScreenPlays/Other/E_player_magic1.prefab")
    list:AddItem("Prefab/ScreenPlays/Other/E_player_magic2.prefab")
    list:AddItem("Prefab/ScreenPlays/Other/E_player_magic_float_idle.prefab")
    AssetLoaderUtil.LoadAssets(list, onLoadFinish)
end

function PlayerBeginFirstFloatAction:DestroyEffects()
    Runtime.CSDestroy(self.effect1)
    Runtime.CSDestroy(self.effect2)
    self.effect1 = nil
    self.effect2 = nil
end

function PlayerBeginFirstFloatAction:Reset()
    self.started = false
    self.isFinished = false

    self:DestroyEffects()
end
return PlayerBeginFirstFloatAction
