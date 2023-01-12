--------------------Job_CheckAutoJumpCbk
local Job_CheckAutoJumpCbk = {}

function Job_CheckAutoJumpCbk:Init(priority)
    self.name = priority
end

function Job_CheckAutoJumpCbk:CheckPop()
    return AppServices.Jump._jumpSceneCbk
end

function Job_CheckAutoJumpCbk:Do(finishCallback)
    AppServices.Jump.PopJumpSceneCallback(finishCallback)
end

return Job_CheckAutoJumpCbk