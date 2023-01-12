--------------------Job_Guide
local Job_Guide = {}

function Job_Guide:Init(priority)
    self.name = priority
end

function Job_Guide:CheckPop()
    return App.mapGuideManager:CheckEnterScenePop(App.scene.params.sceneId)
end

function Job_Guide:Do(finishCallback)
    local start = App.mapGuideManager:EnterScene(App.scene.params.sceneId, finishCallback)
    if not start then
        Runtime.InvokeCbk(finishCallback)
        return
    end
end

return Job_Guide