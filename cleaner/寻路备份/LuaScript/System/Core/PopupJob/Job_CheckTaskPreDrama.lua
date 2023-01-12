--------------------Job_CheckTaskPreDrama
local Job_CheckTaskPreDrama = {}

function Job_CheckTaskPreDrama:Init(priority)
    self.name = priority
end

function Job_CheckTaskPreDrama:CheckPop()
    self.dramaId = AppServices.Task:CheckDramaBeforeMission(App.scene:GetCurrentSceneId())
    return self.dramaId
end

function Job_CheckTaskPreDrama:Do(finishCallback)
    AppServices.Task:playDramaInQueue(self.dramaId, finishCallback)
end

function Job_CheckTaskPreDrama:DoEnd()
    self.dramaId = nil
end

return Job_CheckTaskPreDrama