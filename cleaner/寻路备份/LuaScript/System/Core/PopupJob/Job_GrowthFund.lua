--------------------Job_GrowthFund
local Job_GrowthFund = {}

function Job_GrowthFund:Init(priority)
    self.name = priority
end

function Job_GrowthFund:CheckPop()
    return AppServices.GrowthFundManager:PopCheck()
end

function Job_GrowthFund:Do(finishCallback)
    AppServices.GrowthFundManager:PopDo(finishCallback)
end

return Job_GrowthFund