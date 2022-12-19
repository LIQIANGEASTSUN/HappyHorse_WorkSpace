--------------------Job_Activity
local Job_Activity = {}

function Job_Activity:Init(priority)
    self.name = priority
end

function Job_Activity:CheckPop()
    return true
end

function Job_Activity:Do(finishCallback)
    ActivityServices.ActivityManager:CheckActivity(finishCallback)
end

return Job_Activity