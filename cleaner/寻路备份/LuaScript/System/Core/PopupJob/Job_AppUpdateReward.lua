local Job_AppUpdateReward = {}

function Job_AppUpdateReward:Init(priority)
    self.name = priority
end

function Job_AppUpdateReward:CheckPop()
    return AppUpdateManager:PopupCheck()
end

function Job_AppUpdateReward:Do(finishCallback)
    AppUpdateManager:PopupDo(finishCallback)
end
function Job_AppUpdateReward:DoEnd()
    AppUpdateManager:PopupExit()
end

return Job_AppUpdateReward
