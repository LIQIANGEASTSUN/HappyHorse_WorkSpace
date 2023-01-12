--------------------Job_ExchangeCloseSceneItems
local Job_ExchangeCloseSceneItems = {}

function Job_ExchangeCloseSceneItems:Init(priority)
    self.name = priority
end

function Job_ExchangeCloseSceneItems:CheckPop()
    if App.scene:GetCurrentSceneId() ~= "city" then
        return false
    end

    local needRequest = false
    local closeEntries = AppServices.SceneCloseInfo:GetAllCloseEntries()
    for id in pairs(closeEntries) do
        local isclose = AppServices.SceneCloseInfo:IsSceneClose(id)
        local isClear = AppServices.SceneCloseInfo:IsSceneCloseClear(id)
        if isclose and not isClear then
            self.sceneId = id
            needRequest = true
        end
    end

    return needRequest
end

function Job_ExchangeCloseSceneItems:Do(finishCallback)
    local function onAfterRequest(items)
        if not items then
            return Runtime.InvokeCbk(finishCallback)
        end

        local loseCfg
        for _, v in pairs(items) do
            if v.itemId ~= ItemId.EXP and v.itemId ~= ItemId.COIN then
                local cfg = AppServices.Meta:GetItemMeta(v.itemId)
                if cfg.sellCoin == 0 and cfg.expValue == 0 then
                    loseCfg = true
                    console.warn(nil, "exchangeItem lose reward Cfg :", v.itemId) --@DEL
                    break
                end
            end
        end
        if loseCfg then
            for _, v in pairs(items) do
                if v.ItemId == ItemId.EXP then
                    AppServices.User:AddExp(v.count, "ItemExchange")
                end
                if v.ItemId == ItemId.COIN then
                    AppServices.User:AddItem(ItemId.COIN, v.count, ItemGetMethod.SceneCloseExchangeItem)
                end
                if v.count < 0 then
                    AppServices.User:UseItem(v.itemId, math.abs(v.count), ItemGetMethod.SceneCloseExchangeItem)
                end
            end
            return Runtime.InvokeCbk(finishCallback)
        end

        PanelManager.showPanel(GlobalPanelEnum.ItemExchangePanel, {exchangeItems = items, sceneId = self.sceneId, finishCallback = finishCallback})
    end

    local function _onSuc(response)
        local items = {}
        for _, v in ipairs(response.items) do   --服务器传的道具数量变化量（也包括奖励的经验和金币，有正负值）
            if v.itemTemplateId then
                table.insert(items, {itemId = v.itemTemplateId, count = v.count})
            end
        end
        if table.isEmpty(items) then
            Runtime.InvokeCbk(onAfterRequest, false)
        else
            Runtime.InvokeCbk(onAfterRequest, items)
        end
    end

    local function _onFail(eCode)
        Runtime.InvokeCbk(onAfterRequest, false)
        ErrorHandler.ShowErrorPanel(eCode)
    end

    Net.Scenemodulemsg_25317_ConvertSceneCloseItem_Request(nil, _onFail, _onSuc)
end

function Job_ExchangeCloseSceneItems:DoEnd()
    self.sceneId = nil
end

return Job_ExchangeCloseSceneItems