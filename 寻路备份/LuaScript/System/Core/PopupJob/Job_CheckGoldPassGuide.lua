--------------------Job_CheckGoldPassGuide
local Job_CheckGoldPassGuide = {}

function Job_CheckGoldPassGuide:Init(priority)
    self.name = priority
end

function Job_CheckGoldPassGuide:CheckPop()
    return ActivityServices.GoldPass:CheckPop()
end

function Job_CheckGoldPassGuide:Do(finishCallback)
    ActivityServices.GoldPass:CheckGuide(finishCallback)
end

return Job_CheckGoldPassGuide