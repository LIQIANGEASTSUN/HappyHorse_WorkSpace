
local PlayBuildingEffect = class(BaseFrameAction, "PlayBuildingEffect")

function PlayBuildingEffect:Create(name, anim, finishCallback)
    local instance = PlayBuildingEffect.new(name, anim, finishCallback)
    return instance
end

function PlayBuildingEffect:ctor(name, anim, finishCallback)
    self.name = "PlayBuildingEffect"
    self.started = false
    self.finishCallback = finishCallback

    self.anim = anim
    self.name = name
end

function PlayBuildingEffect:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function PlayBuildingEffect:Awake()
    local function OnFinished()
        self.isFinished = true
    end
    self.isFinished = true
    BuildingEffectManager.Instance():OnBling(self.name, OnFinished)
end

function PlayBuildingEffect:Reset()
    self.started = false
    self.isFinished = false
end

return PlayBuildingEffect