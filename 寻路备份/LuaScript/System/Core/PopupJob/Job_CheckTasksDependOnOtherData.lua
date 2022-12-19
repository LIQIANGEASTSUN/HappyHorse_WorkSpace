--------------------CheckTasksDependOnOtherData
local CheckTasksDependOnOtherData = {}

function CheckTasksDependOnOtherData:Init(priority)
    self.name = priority
end

function CheckTasksDependOnOtherData:CheckPop()
    return true
end

function CheckTasksDependOnOtherData:Do(finishCallback)
    AppServices.Task:CheckTaskDependOnOtherData(finishCallback)
end

return CheckTasksDependOnOtherData