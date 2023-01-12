--------------------Job_ShowGift
local Job_ShowGift = {}

function Job_ShowGift:Init(priority)
    self.name = priority
end

function Job_ShowGift:CheckPop()
    return AppServices.GiftManager:PopCheck()
end

function Job_ShowGift:Do(finishCallback)
    AppServices.GiftManager:PopDo(finishCallback)
end

return Job_ShowGift