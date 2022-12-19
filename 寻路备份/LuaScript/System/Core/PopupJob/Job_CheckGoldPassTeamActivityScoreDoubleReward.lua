--------------------Job_CheckGoldPassTeamActivityScoreDoubleReward
local Job_CheckGoldPassTeamActivityScoreDoubleReward = {}

function Job_CheckGoldPassTeamActivityScoreDoubleReward:Init(priority)
    self.name = priority
end

function Job_CheckGoldPassTeamActivityScoreDoubleReward:CheckPop()
    self._checkActivityId = nil
    ---@type TeamMapActivity
    local teamMap = ActivityServices.ActivityManager:GetActivityInsByType(ActivityType.TeamMapActivity)
    if teamMap and teamMap:IsInActivityTime() and teamMap:IsUnlock() and
        (teamMap:HaveScorePassReward() or teamMap:HaveScoreReward())
        then
        self._checkActivityId = teamMap:GetActivityId()
        return true
    end

    ---@type TeamDragonActivity
    local teamDragon = ActivityServices.ActivityManager:GetActivityInsByType(ActivityType.TeamDragonActivity)
    if teamDragon and teamDragon:IsInActivityTime() and teamDragon:IsUnlock() and
        (teamDragon:HaveScorePassReward() or teamDragon:HaveScoreReward())
        then
        self._checkActivityId = teamDragon:GetActivityId()
        return true
    end

    return false
end

function Job_CheckGoldPassTeamActivityScoreDoubleReward:Do(finishCallback)
    local ins = ActivityServices.ActivityManager:GetInstance(self._checkActivityId)
    if not ins then
        Runtime.InvokeCbk(finishCallback)
        return
    end
    ins:ShowPanelInQueeue(finishCallback)
end

return Job_CheckGoldPassTeamActivityScoreDoubleReward