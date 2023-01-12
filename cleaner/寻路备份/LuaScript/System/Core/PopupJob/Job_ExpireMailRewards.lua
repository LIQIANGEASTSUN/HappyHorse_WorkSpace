--------------------Job_ExpireMailRewards
local Job_ExpireMailRewards = {}

function Job_ExpireMailRewards:Init(priority)
    self.name = priority
end

function Job_ExpireMailRewards:CheckPop()
    return AppServices.MailManager:CheckPopExpireMailReward()
end

function Job_ExpireMailRewards:Do(finishCallback)
    AppServices.MailManager:DoPopExpireMailReward(finishCallback)
end

return Job_ExpireMailRewards