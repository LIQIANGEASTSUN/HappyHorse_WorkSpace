---@class PhotographParticleAction:BaseFrameAction
local PhotographParticleAction = class(BaseFrameAction, "PhotographParticleAction")

function PhotographParticleAction:Create(params, finishCallback)
    local instance = PhotographParticleAction.new(params, finishCallback)
    return instance
end

function PhotographParticleAction:ctor(params, finishCallback)
    self.name = "PhotographParticleAction"
    self.finishCallback = finishCallback
    self.params         = params
end

function PhotographParticleAction:Awake()
    local function onLoadFinish()
        --local pos                   = Vector3(-17.394, 0, -6.643)
        local blink                 = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/Other/E_photo_shan.prefab")
        local particle              = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/Other/E_photograph.prefab")
        blink.name                  = "E_photo_shan"
        --blink.transform.position    = pos
        blink.transform:SetParent(nil, false)
        --particle.transform.position = pos
        particle.name               = "E_photograph"
        particle.transform:SetParent(nil, false)
        self.blink                  = blink
        self.particle               = particle
        self.isFinished = true
    end


    local list = StringList()
    list:AddItem("Prefab/ScreenPlays/Other/E_photo_shan.prefab")
    list:AddItem("Prefab/ScreenPlays/Other/E_photograph.prefab")
    AssetLoaderUtil.LoadAssets(list, onLoadFinish)
end

function PhotographParticleAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function PhotographParticleAction:Reset()
    self.started    = false
    self.isFinished = false
end

return PhotographParticleAction