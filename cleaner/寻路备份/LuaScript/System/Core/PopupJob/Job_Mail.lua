--------------------Job_Mail
local Job_Mail = {}

function Job_Mail:Init(priority)
    self.name = priority
end

function Job_Mail:CheckPop()
    return AppServices.MailManager:CheckPop()
end

function Job_Mail:Do(finishCallback)
    AppServices.MailManager:CheckForcePop(finishCallback)
end

return Job_Mail