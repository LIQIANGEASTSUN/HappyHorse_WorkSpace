--------------------Job_DayReward
local Job_DayReward = {}

function Job_DayReward:Init(priority)
    self.name = priority
end

function Job_DayReward:CheckPop()
    return AppServices.DayRewardManager:CheckQueue()
end

function Job_DayReward:Do(finishCallback)
    AppServices.DayRewardManager:DoQueue(finishCallback)
end

return Job_DayReward