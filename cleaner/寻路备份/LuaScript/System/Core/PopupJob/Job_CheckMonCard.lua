--------------------Job_CheckMonCard
local Job_CheckMonCard = {}

function Job_CheckMonCard:Init(priority)
    self.name = priority
end

function Job_CheckMonCard:CheckPop()
    AppServices.MonCard:Process_PopInit()
    return AppServices.MonCard:PopCheck()
end

function Job_CheckMonCard:Do(finishCallback)
    AppServices.MonCard:PopCheckExpire(finishCallback)
end

return Job_CheckMonCard