--------------------Job_TaskCheck
local Job_TaskCheck = {}

function Job_TaskCheck:Init(priority)
    self.name = priority
end

function Job_TaskCheck:CheckPop()
    return AppServices.Task:CheckOnPlayerEnterScene()
end

function Job_TaskCheck:Do(finishCallback)
    AppServices.Task:OnPlayerEnterScene(App.scene:GetCurrentSceneId(), finishCallback)
end

return Job_TaskCheck