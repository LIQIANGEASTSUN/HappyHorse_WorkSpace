--------------------Job_CheckDressingHut
local Job_CheckDressingHut = {}

function Job_CheckDressingHut:Init(priority)
    self.name = priority
end

function Job_CheckDressingHut:CheckPop()
    if not App.scene:IsMainCity() then
        return false
    end
    if not AppServices.DragonMaze:IsUnlock() or not AppServices.Unlock:IsUnlock("equipProduct") then
        return false
    end
    local mgr = App.mapGuideManager
    if mgr:HasComplete(GuideIDs.GuideDressingProduce) then
        return false
    end
    local exploreLevel = AppServices.DragonMaze:GetMazeLevel(1)
    if exploreLevel > 2 then
        mgr:MarkGuideComplete(GuideIDs.GuideDressingProduce)
        return false
    elseif exploreLevel < 2 then
        return false
    end
    if not mgr:HasComplete(GuideIDs.GuideDressingBuy) then
        --[[local count = AppServices.User:GetItemAmount("2200")    --取消一下这个限制了,材料不够时帽子那么有要求制作，只是告诉了如果材料不够再去迷宫获取by:xieyanjiao
        if count < 100 then
            mgr:MarkGuideComplete(GuideIDs.GuideDressingProduce)
            return false
        end--]]
        return false
    end
    return true
end

function Job_CheckDressingHut:Do(finishCallback)
    App.mapGuideManager:StartSeries(GuideConfigName.GuideDressingHut)
    App.mapGuideManager:SetGuideFinishCallback(finishCallback)
end

return Job_CheckDressingHut