--------------------Job_CheckReopenMapEnd
local Job_CheckReopenMapEnd = {}

function Job_CheckReopenMapEnd:Init(priority)
    self.name = priority
end

function Job_CheckReopenMapEnd:CheckPop()
    if not AppServices.MapStarManager:IsABUnlock() then
        return false
    end

    -- local reopenMapRecords = AppServices.User.Default:GetKeyValue("ReopenMap", {})

    local curSceneId = App.scene:GetCurrentSceneId()
    -- local costed = reopenMapRecords[curSceneId]
    -- console.lh("CheckReopenMapEnd: ", costed) --@DEL
    -- if not costed then
    --     return false
    -- end
    local sceneNames = CONST.GAME.SCENE_NAMES
    if not table.exists(sceneNames, curSceneId) then
        return false
    end

    local closeTime = AppServices.SceneCloseInfo:GetSceneCloseTime(curSceneId)
    if not closeTime then
        return false
    end

    local isclose = AppServices.SceneCloseInfo:IsSceneClose(curSceneId)
    if not isclose then
        AppServices.MapStarManager:StartReopenCountdown(curSceneId, closeTime)
        return false
    end

    return true
end

function Job_CheckReopenMapEnd:Do(finishCallback)
    local curSceneId = App.scene:GetCurrentSceneId()
    return PanelManager.showPanel(GlobalPanelEnum.ReopenMapPanel,{sceneId = curSceneId, finishCallback = finishCallback})
end

return Job_CheckReopenMapEnd