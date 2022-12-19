local PlaySmokeAction = class(BaseFrameAction, "PlaySmokeAction")

function PlaySmokeAction:Create(params, finishCallback)
    local instance = PlaySmokeAction.new(params, finishCallback)
    return instance
end

function PlaySmokeAction:ctor(params, finishCallback)
    self.name = "PlaySmokeAction"
    self.finishCallback = finishCallback
    self.position = params.Position
    self.scale = params.Scale
end

function PlaySmokeAction:Awake()

    local function onLoadFinish()
        local smoke = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/E_clear_common.prefab")
        smoke.transform.position = self.position or Vector3(0, 0, 0)
        smoke.transform.localScale = self.scale or Vector3(1, 1, 1)
        Runtime.CSDestroy(smoke, 2)
        self.isFinished = true
    end

    local list = StringList()
    list:AddItem("Prefab/ScreenPlays/E_clear_common.prefab")
    AssetLoaderUtil.LoadAssets(list, onLoadFinish)
end

function PlaySmokeAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function PlaySmokeAction:Reset()
    self.started = false
    self.isFinished = false
end

return PlaySmokeAction