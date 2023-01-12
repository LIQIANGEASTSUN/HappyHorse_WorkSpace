
local StartComic = class(BaseFrameAction, "StartComic")

function StartComic:Create(params, finishCallback)
    local instance = StartComic.new(params, finishCallback)
    return instance
end

function StartComic:ctor(params, finishCallback)
    self.name = "StartComic"
    self.started = false
    self.comicsName = params.name
    self.chapter = params.chapter
    self.finishCallback = finishCallback
    self.dontIdle = params.dontIdle
    self.dontKill = params.dontKill
end

function StartComic:Awake()
    local params = {chapter = self.chapter, name = self.comicsName, dontSetNpcIdle = self.dontIdle, dontKill = self.dontKill}
    print("Start Comics ", self.comicsName, self.dontKill) --@DEL

    local asset_name = "Prefab/UI/Common/ScreenPlays/ComicsPanel.prefab"
    local function onAssetLoaded()
        params.render = BResource.InstantiateFromAssetName(asset_name)
        local panel = require "UI.ScreenPlays.UI.ComicsPanel"
        panel.Create(params, function()
            self.isFinished = true
        end)
    end
    App.uiAssetsManager:LoadAssets({asset_name,}, onAssetLoaded)
end

function StartComic:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function StartComic:Reset()
    self.started = false
    self.isFinished = false
end

return StartComic