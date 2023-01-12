---@class GetWay
local GetWay = {}

local handleGetType = {
    [GetWayType.Text] = function(itemId)
        local meta = AppServices.Meta:GetItemMeta(itemId)
        local key = meta.getWayParam
        local str = Runtime.Translate(key)
        AppServices.UITextTip:Show(str)
    end,
    [GetWayType.diamondShop] = function(itemId)
        local isShowAll
        local horizontalNormalizedPosition
        if itemId == ItemId.DRAGONBREED then
            isShowAll = true
            horizontalNormalizedPosition = 1
        end
        AppServices.Jump.JumpShop(
            2,
            GlobalPanelEnum.BagPanel,
            function()
                PanelManager.showPanel(GlobalPanelEnum.BagPanel)
            end,
            isShowAll,
            horizontalNormalizedPosition
        )
    end,
    [GetWayType.factory] = function(itemId)
        ---@type FactoryMainPanel
        local factoryMainPanel = PanelManager.GetPanel(GlobalPanelEnum.FactoryMainPanel.panelName)
        if factoryMainPanel then
            if PanelManager.isPanelShowing(GlobalPanelEnum.BuyItemPanel) then
                PanelManager.closePanel(GlobalPanelEnum.BuyItemPanel)
            end
            factoryMainPanel:JumpInFactory(itemId)
        else
            PanelManager.closeAllPanels()
            local canProduct, needLevel = AppServices.FactoryManager:CanProduct(itemId)
            if canProduct then
                AppServices.Jump.FocusFactory(itemId)
            else
                AppServices.UITextTip:Show(Runtime.Translate("ui_system_unlock_level", {level = tostring(needLevel)}))
            end
        end
    end,
    [GetWayType.dragon] = function(itemId)
        AppServices.Jump.FocusDragonByItem(itemId)
    end,
    [GetWayType.clean] = function(itemId, showArrow)
        PanelManager.closeAllPanels()
        if showArrow == nil then
            showArrow = true
        end
        return AppServices.Jump.AutoByItemId(
            itemId,
            GlobalPanelEnum.BagPanel,
            AutoJumpType.ShowWorldMapOnly,
            nil,
            showArrow
        )
    end,
    [GetWayType.coinShop] = function(_, backPanel, param)
        AppServices.Jump.JumpShop(
            1,
            backPanel or GlobalPanelEnum.BagPanel,
            function()
                PanelManager.showPanel(backPanel or GlobalPanelEnum.BagPanel, param)
            end
        )
    end,
    [GetWayType.open] = function(itemId)
        local params = {
            itemTemplateId = itemId,
            count = 1
        }
        local function onFail(errorCode)
            PanelManager.closeAllPanels()
            ErrorHandler.ShowErrorPanel(errorCode)
        end

        local function onSuc(msg)
            AppServices.User:UseItem(params.itemTemplateId, params.count, ItemUseMethod)
            -- PanelManager.closeAllPanels()
            --PanelManager.hidePanel(GlobalPanelEnum.BagPanel)
            PanelManager.closePanel(GlobalPanelEnum.BagPanel)
            local response = Net.Converter.ConvertUseItemResponse(msg)
            local rwds = {}
            for _, item in pairs(response.items) do
                local amount = AppServices.User:GetItemAmount(item.itemTemplateId)
                local delta = {
                    ItemId = item.itemTemplateId,
                    Amount = item.count - amount
                }
                table.insert(rwds, delta)

                AppServices.User:SetPropNumber(item.itemTemplateId, item.count)
            end
            local function onClosecbk()
                -- PanelManager.showPanel(GlobalPanelEnum.BagPanel, {prePos = true})
                -- if bagItem then
                --     bagItem:Refresh()
                -- end
                PanelManager.showPanel(GlobalPanelEnum.BagPanel, {prePos = true})
                MessageDispatcher:SendMessage(MessageType.GetWay_Open_Closed, itemId)
            end
            PanelManager.showPanel(GlobalPanelEnum.CommonRewardPanel, {rewards = rwds, closeCallback = onClosecbk})
        end
        Net.Itemmodulemsg_2002_UseItem_Request(params, onFail, onSuc, nil, true)
    end,
    [GetWayType.lab] = function(_, backPanel, param)
        if AppServices.Unlock:IsUnlockOrShowTip("geneBase") then
            local agent = SceneServices.LabManager:GetAgent()
            if agent and agent:CanBeSeen() then
                PanelManager.closeAllPanels()
                SceneServices.LabManager:ShowMainPanel({crown = true})
            else
                AppServices.UITextTip:Show(Runtime.Translate("ui_gene_10"))
            end
        end
    end,
    [GetWayType.commission] = function(itemId)
        PanelManager.closeAllPanels()
        local meta = AppServices.Meta.metas.CommissionTemplate
        local param = {
            state = 0,
            sceneId = nil
        }
        local function set(sceneId, state)
            param.sceneId = sceneId
            param.state = state
        end
        local validators = CONST.RULES.SceneUnlocked
        for _, v in pairs(meta) do
            if tostring(v.reward[1][1]) == itemId then
                local unlocked = validators(v.sceneID)
                local stars = AppServices.SceneCloseInfo:GetSceneStarEx(v.sceneID)
                local usable = #stars == 3
                local state = usable and 3 or unlocked and 1 or 0
                if param.sceneId then
                    if param.state < state then
                        set(v.sceneID, state)
                    elseif param.state == state then
                        local tId = tonumber(v.sceneID)
                        local sId = tonumber(param.sceneId)
                        if state == 0 then
                            if tId < sId then
                                set(v.sceneID, state)
                            end
                        else
                            if tId > sId then
                                set(v.sceneID, state)
                            end
                        end
                    end
                else
                    set(v.sceneID, state)
                end
            end
        end
        AppServices.Jump.Command_ToCommission(param.sceneId)
    end,
    [GetWayType.farmland] = function(itemId)
        PanelManager.closeAllPanels()
        AppServices.Jump.FocusFarmLand(itemId)
    end,
    [GetWayType.useGene] = function(itemId)
        -- if AppServices.Unlock:IsUnlockOrShowTip("geneBase") then
        --     local agent = SceneServices.LabManager:GetAgent()
        --     if agent and agent:CanBeSeen() then
        --         PanelManager.closeAllPanels()
        --         AppServices.Jump.FocusLab({gene = true})
        --     else
        --         AppServices.UITextTip:Show(Runtime.Translate("ui_gene_10"))
        --     end
        -- else
        --     AppServices.Jump.FocusLab({gene = true})
        -- end

        PanelManager.closeAllPanels()
        AppServices.Jump.FocusLabWithCheck({gene = true})
    end,
    [GetWayType.map] = function(sceneId)
        if not sceneId then
            return
        end
        PanelManager.closeAllPanels()
        local mapProcessor = require "UI.HomeScene.WorldMapPanel.OpenWorldMapProcessor"
        mapProcessor.Start({targetSceneId = sceneId})
    end,
    [GetWayType.maze] = function(itemId)
        if App.scene:GetSceneType() == SceneType.Maze then
            if AppServices.Jump.FocusByItemId2AgentTemplate(itemId) then
                PanelManager.closeAllPanels()
            else
                AppServices.UITextTip:Show(Runtime.Translate("item_getway_2200"))
            end
        else
            PanelManager.closeAllPanels()
            AppServices.Jump.FocusMazeEntry()
        end
    end,
    [GetWayType.dress] = function(itemId)
        PanelManager.closeAllPanels()
        PanelManager.showPanel(GlobalPanelEnum.UserInfoPanel, {targetSkin = itemId})
    end,
    [GetWayType.dragonDress] = function(itemId)
        PanelManager.closeAllPanels()
        AppServices.Jump.FocusDragonInfoBuilding()
    end,
    [GetWayType.dressHouse] = function(itemId)
        local UnlockKey = "equipProduct"
        if AppServices.Unlock:IsUnlockOrShowTip(UnlockKey) then
            PanelManager.closeAllPanels()
            AppServices.Jump.Command_ToDressingHut({tplId = itemId})
        else
            local skinConfig = AppServices.Meta:Category("SkinTemplate")[itemId]
            if skinConfig then
                AppServices.UITextTip:Show(Runtime.Translate(skinConfig.drawingGetWayDesc))
            end
        end
    end,
    [GetWayType.marathon] = function()
        PanelManager.closeAllPanels()
        return AppServices.Jump.FocusAgentByObstacleType(AgentType.obstacle, true, false, true, LookUpWay.NearPlayer)
    end,
}

local GetWayTextKey = {
    [GetWayType.factory] = function(itemId)
        local factoryId, config = AppServices.FactoryManager:GetFactoryByItem(itemId)
        if factoryId then
            return config.name, "ui_common_get"
        end
    end,
    [GetWayType.dragon] = function(itemId)
        local configs = AppServices.MagicalCreatures:GetConfigsByProduct(itemId)
        return configs and configs[1] and configs[1].name, "ui_common_get"
    end,
    [GetWayType.open] = function()
        return "ui_dragonHelpBox_open"
    end,
    [GetWayType.lab] = function()
        return "ui_gene_11"
    end,
    [GetWayType.clean] = function()
        return "UI_getway_tansuo"
    end,
    [GetWayType.commission] = function()
        return "UI_getway_commission"
    end,
    [GetWayType.useGene] = function()
        return "ui_gene_11"
    end,
    [GetWayType.dress] = function()
        return "UI_bagSkin_npc_button1"
    end,
    [GetWayType.dragonDress] = function()
        return "UI_bagSkin_npc_button1"
    end
}

setmetatable(
    GetWayTextKey,
    {
        __index = function(t, k)
            return function()
                return "ui_common_get"
            end
        end
    }
)

local checkGetWayUnlock = {
    [GetWayType.commission] = function()
        return AppServices.Unlock:IsUnlock("commission")
    end
}

function GetWay.getWays(itemId)
    local cfg = AppServices.Meta:GetItemMeta(itemId)
    if not table.isEmpty(cfg.getWays) then
        return cfg.getWays
    else
        return {cfg.getWay}
    end
end

function GetWay.get(itemId, specifiedGetWays)
    local handles = {}
    local ways = specifiedGetWays and specifiedGetWays or GetWay.getWays(itemId)
    for _, w in ipairs(ways) do
        local h = handleGetType[w]
        if not checkGetWayUnlock[w] or checkGetWayUnlock[w]() then
            local strKey1, strKey2 = GetWayTextKey[w](itemId)
            table.insert(handles, {str = strKey1, str2 = strKey2, handle = h})
        end
    end
    return handles
end

return GetWay
