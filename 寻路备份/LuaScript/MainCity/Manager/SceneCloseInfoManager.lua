---@class SceneCloseInfoManager
local SceneCloseInfoManager = {
    closes = {},        --场景关闭信息（关闭时间点，以及是否兑换过关闭道具）包括活动场景地图
    star = {},          --场景三星信息
    sceneRewards = {}   --场景完成奖励
}

function SceneCloseInfoManager:AddListeners()
    MessageDispatcher:AddMessageListener(MessageType.MapStar_StarTask_AllDone, self.RefreshSceneStar, self)
end

function SceneCloseInfoManager:GetAllCloseEntries()
    return self.closes
end

function SceneCloseInfoManager:GetCloseEntry(sceneId)
    return self.closes[sceneId] or {}
end

function SceneCloseInfoManager:GetSceneCloseTime(sceneId)
    if not self.closes[sceneId] then
        console.lh("scene hasnot activate close", sceneId)  --@DEL
        return
    end
    return self.closes[sceneId].closeTime / 1000
end

function SceneCloseInfoManager:IsSceneCloseClear(sceneId)
    if not self.closes[sceneId] then
        console.lh("scene hasnot activate close", sceneId)  --@DEL
        return
    end
    return self.closes[sceneId].closeClear
end

function SceneCloseInfoManager:IsSceneClose(sceneId)
    if not self.closes[sceneId] then
        return false
    end
    return (self.closes[sceneId].closeTime - TimeUtil.ServerTimeMilliseconds()) < 0
end

function SceneCloseInfoManager:RefreshSceneCloseInfo(sceneId, closeTime)
    if not self.closes[sceneId] then
        self.closes[sceneId] = {}
    end
    self.closes[sceneId].closeTime = closeTime
    self.closes[sceneId].closeClear = false
end

function SceneCloseInfoManager:IsSceneRewardObtained(sceneId)
    return self.sceneRewards[sceneId]
end

function SceneCloseInfoManager:RefreshCompleteReward(sceneId)
    self.sceneRewards[sceneId] = true
end

------------------------sceneStar---------------------------
--世界地图三星信息专用
function SceneCloseInfoManager:GetSceneStarEx(sceneId)
    return self.star[sceneId] or {}
end

function SceneCloseInfoManager:GetAllSceneStar()
    return self.star
end

function SceneCloseInfoManager:RefreshSceneStar(sceneId, starId)
    if not self.star[sceneId] then
        self.star[sceneId] = {}
    end
    if table.exists(self.star[sceneId], starId) then
        console.warn(nil, "重复加星,请检查：", sceneId, starId)    --@DEL
    end
    table.insert(self.star[sceneId], starId)
end

-------------------------服务器协议---------------------------
---@param reqType number 请求类型: 1.地图 2.委托
function SceneCloseInfoManager:Request(reqType, callback)
    self.closes = {}
    self.star = {}
    local function _onSuc(result)
        for _, sceneInfo in ipairs(result.closeEntries) do
            local sceneId = sceneInfo.sceneId
            if sceneId then
                self.closes[sceneId] = {}
                self.closes[sceneId].closeTime = sceneInfo.closeTime
                self.closes[sceneId].closeClear = sceneInfo.closeClear
            end
        end
        SceneServices.RuinsSceneManager.OnResponseSceneCloseInfo(result)

        for _, starInfo in ipairs(result.star) do
            local sceneId = starInfo.sceneId
            if sceneId then
                self.star[sceneId] = {}
                for _, id in ipairs(starInfo.starIds or {}) do
                    table.insert(self.star[sceneId], id)
                end
            end
        end

        for _, v in ipairs(result.complateRewardSceneIds or {}) do
            self.sceneRewards[v] = true
        end

        if reqType == 2 then
            AppServices.CommissionManager:InitOpenCommissions(result.unlockCommissionIds)
        end

        Runtime.InvokeCbk(callback, true)
    end

    local function _onFail(eCode)
        Runtime.InvokeCbk(callback, false)
        ErrorHandler.ShowErrorPanel(eCode)
    end

    Net.Scenemodulemsg_25313_SceneCloseTime_Request({reqType = reqType}, _onFail, _onSuc)
end

return SceneCloseInfoManager
