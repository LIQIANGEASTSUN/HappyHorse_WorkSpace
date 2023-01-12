--------------------Job_Piggybank
local Job_Piggybank = {}

function Job_Piggybank:Init(priority)
    self.name = priority
end

function Job_Piggybank:CheckPop()
    return AppServices.PiggyBank:CheckPopupQueue()
end

function Job_Piggybank:Do(finishCallback)
    AppServices.ProductManager:CheckFetchAll(function (result)
        if result then
            AppServices.PiggyBank:OnPopupQueue(finishCallback)
        else
            Runtime.InvokeCbk(finishCallback)
        end
    end)
end

return Job_Piggybank