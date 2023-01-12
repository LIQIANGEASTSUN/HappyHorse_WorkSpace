require("MainCity.Component.Bubble.Bubble_base")
---@class Bubble_Breed
local Bubble_Breed = class(Bubble_Interface, "Bubble_Breed")

function Bubble_Breed:ctor()
    self.type = BubbleType.Breed
    self.canClick = true
    self.needCache = true
end

function Bubble_Breed:InitData(param)
    local agent = App.scene.objectManager:GetAgent(param.agentId)
    if not agent or Runtime.CSNull(agent:GetGameObject()) then
        return
    end
    self:SetPosition(agent:GetAnchorPosition())
    -- self.breedInfo = param.data
    local normal = find_component(self.gameObject, "bg/normal")
    local multi = find_component(self.gameObject, "bg/multi")

    local isMulti = SceneServices.BreedManager:IsMultiBreed()
    normal:SetActive(not isMulti)
    multi:SetActive(isMulti)
end

function Bubble_Breed:onBubbleClick()
    local breedManager = SceneServices.BreedManager

    local function getItemReward(productItems, dragonId, dragonCount)
        Util.BlockAll(0, "BreedClickBubble")
        if not productItems or (#productItems == 0 and dragonCount == 0) then
            return
        end

        local rwds = {}
        if dragonId then
            for index = 1, dragonCount do
                table.insert(rwds, {ItemId = dragonId, Amount = 1})
            end
        end
        WaitExtension.InvokeDelay(
            function()
                MessageDispatcher:SendMessage(MessageType.Global_After_BreedDragon, dragonId, dragonCount)
            end
        )
        for i, v in ipairs(productItems) do
            table.insert(rwds, {ItemId = v.itemTemplateId, Amount = v.count})
        end

        local closeCallback = function()
            local function idleDo()
                if
                    not App.mapGuideManager:HasComplete(GuideConfigName.GuideTemporaryNest) and
                        table.count(AppServices.MagicalCreatures:GetCreaturesInBag()) > 0
                 then
                    App.mapGuideManager:StartSeries(GuideConfigName.GuideTemporaryNest)
                else
                    PanelManager.showPanel(GlobalPanelEnum.BreedMainPanel, {selectId = RuntimeContext.preBreedDragonId})
                end
            end

            local function checkFunc()
                local anchoredPosition = App.scene.view.layout:BottomLeft().anchoredPosition
                return anchoredPosition.y > 6
            end

            PopupManager:CallWhenIdle(idleDo, checkFunc)
        end

        PanelManager.showPanel(
            GlobalPanelEnum.CommonRewardPanel,
            {
                rewards = rwds,
                donotSort = true,
                showInSequence = #rwds > 1,
                --useDragonIcon = true,
                isEntity = true,
                fadeIn = true,
                showCongrats = true,
                useGrid = #rwds > 5
            },
            PanelCallbacks:Create(closeCallback)
        )
    end

    ---@param entity Dragon dragonData MagicalCreatureMsg
    ---@param dragonData MagicalCreatureMsg
    local function getDragon(entity, dragonData, productItems, dragonCount)
        local happyFinished = function()
            if not entity then
                return
            end
            entity.retainPos = true
            entity:ChangeAction(EntityState.idle)
        end

        local rewardFinished = function()
            if not entity then
                return
            end
            entity:PlayHappy()
            WaitExtension.SetTimeout(happyFinished, 1)
        end

        -- local templateId = entity and entity.data.templateId or dragonData and dragonData.templateId
        local function closePanel()
            if entity then
                entity:SetVisible(true)
                local pos, angle = SceneServices.BreedManager:GetBornPosAndAngle()
                entity.render.transform.localEulerAngles = Vector3(0, angle, 0)
                entity.gameObject:SetPosition(pos)
                entity:PlayRandomIdle()
                entity:GetOrCreateProductBehaviour():CollectBreedReward()
                WaitExtension.SetTimeout(rewardFinished, 1)
            end
            -- WaitExtension.InvokeDelay(
            --     function()
            --         MessageDispatcher:SendMessage(MessageType.Global_After_BreedDragon, templateId, dragonCount)
            --     end
            -- )
            local dragonId
            if entity then
                dragonId = entity.meta.id
            elseif dragonData then
                dragonId = dragonData.templateId
            end
            -- getItemReward(productItems, dragonId, dragonCount)
            MessageDispatcher:SendMessage(MessageType.Global_After_BreedDragon, dragonId, dragonCount)
            PopupManager:CallWhenIdle(
                function()
                    PanelManager.showPanel(GlobalPanelEnum.BreedMainPanel, {selectId = RuntimeContext.preBreedDragonId})
                end
            )
        end

        local function showReward(id)
            Util.BlockAll(0, "BreedClickBubble")
            PanelManager.showPanel(
                GlobalPanelEnum.BreedResultPanel,
                {id = id, count = dragonCount, toBag = entity == nil},
                PanelCallbacks:Create(closePanel)
            )
        end

        if entity then
            showReward(entity.meta.id)
        elseif dragonData then
            showReward(dragonData.templateId)
        end
    end

    local function getReward(entity, dragonData, productItems, dragonCount)
        -- self.breedInfo = nil
        if entity or dragonData then
            getDragon(entity, dragonData, productItems, dragonCount)
        else
            getItemReward(productItems)
        end
    end
    local breedId = SceneServices.BreedManager.breedId
    local productConfig = breedManager:GetBreedProductConfig()

    ---@param entity Dragon
    local function requestCallback(result, entity, dragonData, productItems, dragonCount)
        if not result then
            return
        end

        local pcb =
            PanelCallbacks:Create(
            function()
                if dragonCount + #productItems > 1 then
                    local dragonId
                    if dragonData then
                        dragonId = dragonData.templateId
                    elseif entity then
                        dragonId = entity.data.templateId
                    end
                    getItemReward(productItems, dragonId, dragonCount)
                else
                    getReward(entity, dragonData, productItems, dragonCount)
                end
            end
        )
        local getInfos = {}
        local hasDragon
        -- while showItemCount + showDragonCount < dragonCount + #productItems do
        --     table.insert(getInfos, table.pack(getItemIdAndCount()))
        -- end
        if dragonCount > 0 then
            local dragonId
            if dragonData then
                dragonId = dragonData.templateId
            elseif entity then
                dragonId = entity.data.templateId
            end
            table.insert(getInfos, {dragonId, 1})
            hasDragon = true
        else
            table.insert(getInfos, {productItems[1].itemTemplateId, productItems[1].count})
        end

        Util.BlockAll(0, "BreedClickBubble")
        PanelManager.showPanel(
            GlobalPanelEnum.BreedRandomPanel,
            {rewardItems = productConfig.product, getInfos = getInfos, hasDragon = hasDragon},
            pcb
        )
        if breedId ~= nil then
            local count = SceneServices.BreedManager:GetBreedCount(breedId) - 1
            local productConfig = SceneServices.BreedManager:GetCreatureProductConfig()[breedId]
            local costNeedCount = math.floor(productConfig.needItem[2] * math.pow(productConfig.needItem[3], count))
            DcDelegates:Log(
                SDK_EVENT.front_breeding_dragon,
                {
                    itemId = getInfos[1][1],
                    parents = breedId,
                    consume = CONST.RULES.ConvertLogItem({{productConfig.needItem[1], costNeedCount}})
                }
            )
        --console.error("front_breeding_dragon", getItemId, breedId, costNeedCount)
        end
    end

    Util.BlockAll(7, "BreedClickBubble")
    SceneServices.BreedManager:BreedRewardRequest(requestCallback, productConfig.id)
end

return Bubble_Breed
