
local StartCartoon = class(BaseFrameAction, "StartCartoon")

function StartCartoon:Create(cartoonName, chapter, name, finishCallback)
    local instance = StartCartoon.new(cartoonName, chapter, name, finishCallback)
    return instance
end

function StartCartoon:ctor(cartoonName, chapter, name, finishCallback)
    self.name = "StartCartoon"
    self.started = false
    self.cartoonName = cartoonName
    self.name = name
    self.chapter = chapter
    self.finishCallback = finishCallback
end

function StartCartoon:Awake()
    local function OnFinished()
        self.isFinished = true
    end
    local CartoonPanel = require "UI.ScreenPlays.UI.CartoonPanel"
    CartoonPanel:Create(self.cartoonName, self.chapter, self.name, OnFinished)
end

function StartCartoon:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

return StartCartoon