--------------------Job_CheckTaskChangeScene
local Job_CheckTaskChangeScene = {}

function Job_CheckTaskChangeScene:Init(priority)
    self.name = priority
end

function Job_CheckTaskChangeScene:CheckPop()
    return AppServices.Task:PopupCheck()
end

function Job_CheckTaskChangeScene:Do(finishCallback)
    AppServices.Task:PopupDo(App.scene.params.sceneId, finishCallback)
end

function Job_CheckTaskChangeScene:DoEnd()
    AppServices.Task:PopupExit()
end

return Job_CheckTaskChangeScene