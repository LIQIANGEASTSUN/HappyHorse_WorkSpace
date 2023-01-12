local RequestMapDataProcessor = {}

---请求地图数据并完成场景切换
function RequestMapDataProcessor:Start(name, onSuc, onFailed, extraParam, extraAssets)
    local cfg = CONST.RULES.LoadSceneConfig(name)
    local sceneId = cfg.params.sceneId
    if not sceneId or sceneId == "0" then ---检查场景ID
        ErrorHandler.ShowErrorMessage(string.format("Request map data error,sceneId = %s",sceneId))
        return
    end

    local KeyEventProcessor = require("Game.Processors.KeyEventProcessor")
    extraParam = extraParam or {}
    local function onSuccess(result)
        AppServices.PipeManager:ResponseSceneInfo(sceneId, result.pipeMsgs or {})
        extraParam.serverMapData = self:ConvertSuccessServerData(result, sceneId) or {}
        RuntimeContext.CACHES.SERVER_MAP = extraParam.serverMapData or {}
        if not extraParam.serverMapData then
            Runtime.InvokeCbk(onFailed)
            ErrorHandler.ShowErrorMessage("没有获取到地图数据")
        else
            local ChangeSceneAnimation = require "Game.Common.ChangeSceneAnimation"
            ChangeSceneAnimation.Instance():EnterCityIn(function()
                local function OnChangeSuccess()
                    Runtime.InvokeCbk(onSuc)
                    KeyEventProcessor.Enable = true
                end
                local processor = require "Game.Processors.ChangeSceneProcessor"
                processor.Change(name, OnChangeSuccess, extraParam, extraAssets)
            end)
        end
        AppServices.FarmManager:InitFromServer(result.farmlandMsgs, cfg)
        local starMsg = Net.Converter.ConvertSceneStarMsg(result.starMsg)
        AppServices.MapStarManager:InitTask(sceneId, starMsg)
    end

    local function onFail(eCode)
        extraParam.serverMapData = {}
        RuntimeContext.CACHES.SERVER_MAP = {}
        ErrorHandler.ShowErrorPanel(eCode)
        Runtime.InvokeCbk(onFailed)
        KeyEventProcessor.Enable = true
    end

    KeyEventProcessor.Enable = false
    Net.Scenemodulemsg_25301_SceneInfo_Request({sceneId = cfg.params.sceneId}, onFail, onSuccess)
end

---请求地图数据
function RequestMapDataProcessor:RequestMapData(name, onFinish, onFailed, extraParam, extraAssets)
    local cfg = CONST.RULES.LoadSceneConfig(name)
    local sceneId = cfg.params.sceneId
    if not sceneId or sceneId == "0" then ---检查场景ID
        return Runtime.InvokeCbk(onFailed)
    end

    extraParam = extraParam or {}
    local function onSuccess(result)
        AppServices.PipeManager:ResponseSceneInfo(sceneId, result.pipeMsgs or {})
        extraParam.serverMapData = self:ConvertSuccessServerData(result, sceneId)
        RuntimeContext.CACHES.SERVER_MAP = extraParam.serverMapData or {}
        if not extraParam.serverMapData then
            Runtime.InvokeCbk(onFailed)
        else
            Runtime.InvokeCbk(onFinish, extraParam)
        end
        AppServices.FarmManager:InitFromServer(result.farmlandMsgs, cfg)
        local starMsg = Net.Converter.ConvertSceneStarMsg(result.starMsg)
        AppServices.MapStarManager:InitTask(sceneId, starMsg)
    end
    local function onFail(eCode)
        extraParam.serverMapData = {}
        RuntimeContext.CACHES.SERVER_MAP = {}
        ErrorHandler.ShowErrorPanel(eCode)
        Runtime.InvokeCbk(onFailed)
    end
    Net.Scenemodulemsg_25301_SceneInfo_Request({sceneId = cfg.params.sceneId}, onFail, onSuccess)
end

---处理服务器请求成功数据
function RequestMapDataProcessor:ConvertSuccessServerData(response, sceneId)
    local serverData = {}
    local objectDic = Net.Converter.ConvertDictionary(response.plants, "plantId", Net.Converter.ConvertPlantMsg) or {}
    serverData.objects = objectDic ---消除中的障碍物数据

    local clearedObjs = Net.Converter.ConvertArray(response.cleared) or {}
    if clearedObjs and #clearedObjs > 0 then
        local clearedIds = {}
        for _, id in ipairs(clearedObjs) do
            clearedIds[id] = true
        end
        serverData.cleared = clearedIds ---已经清除完的障碍物ID字典,dic<id,true>
    end
    ---切换场景自动领取奖励信息数据[数组]
    serverData.autoReceivedCollectRewards = Net.Converter.ConvertArray(response.autoReceivedCollectRewards, Net.Converter.ConvertItemMsg) or {}

    local monsterMsgs = Net.Converter.ConvertDictionary(response.monsterMsgs, "plantId", Net.Converter.ConvertMonsterMsg) or {}
    serverData.monsterMsgs = monsterMsgs
    serverData.appears = Net.Converter.ConvertArray(response.appears)
    AppServices.AgentAppear:InitFromResponse(sceneId, serverData.appears)
    local buildingrepairs = response.buildingMsgs
    if buildingrepairs and #buildingrepairs > 0 then
        local buildingMsgs = Net.Converter.ConvertDictionary(response.buildingMsgs, "plantId", Net.Converter.ConvertBuildingMsg) or {}
        -- AppServices.BuildingRepair:InitFromResponse(sceneId, buildingMsgs)
        serverData.buildingMsgs = buildingMsgs
    end
    local limitTimePlantsMsgs = response.limitTimePlants
    if limitTimePlantsMsgs and #limitTimePlantsMsgs > 0 then
        local limitTimePlants = Net.Converter.ConvertDictionary(response.limitTimePlants, "plantId", Net.Converter.ConvertLimitTimePlant) or {}
        serverData.limitTimePlants = limitTimePlants
    end
    serverData.convertFactorys = Net.Converter.ConvertFactorysResponse(response.convertFactorys) or {}
    serverData.creatures = Net.Converter.ConvertArray(response.creatures, Net.Converter.ConvertMagicalCreatureMsg) or {}
    serverData.dropPlantIds = Net.Converter.ConvertArray(response.dropPlantIds)
    return serverData
end

return RequestMapDataProcessor
