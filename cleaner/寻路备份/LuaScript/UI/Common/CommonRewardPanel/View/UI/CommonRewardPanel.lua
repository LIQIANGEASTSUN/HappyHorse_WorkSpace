--insertWidgetsBegin
--	BuildingContainer	text_continue	btn_hitLayer
--insertWidgetsEnd

--insertRequire
local _CommonRewardPanelBase = require "UI.Common.CommonRewardPanel.View.UI.Base._CommonRewardPanelBase"
---@class CommonRewardPanel : _CommonRewardPanelBase
local CommonRewardPanel = class(_CommonRewardPanelBase)
local RewardItem = require("UI.Components.RewardItem")
local DragonRewardItem

function CommonRewardPanel:ctor()
    ---@type RewardItem[]
    self.flyItems = {}
end

function CommonRewardPanel:onAfterBindView()
    self.btn_nextLayer:SetActive(false)
    local showCongrats = self.arguments.showCongrats
    -- self:InitRewards(rewards)
    self.txt_congrats.text = self.arguments.congratsStr or Runtime.Translate("ui_shop_congratulations")
    self.txt_congrats:SetActive(showCongrats)
    self.txt_name:SetActive(false)
    self.txt_dragon_product:SetActive(false)
    self.productLimit:SetActive(false)

    self.container_items:SetSpacing(25)
    self.mark:SetActive(false)
    if self.arguments.desc1 then
        self.txt_desc1:SetActive(true)
        self.txt_desc1.text = self.arguments.desc1
    else
        self.txt_desc1:SetActive(false)
    end
    if self.arguments.desc2 then
        self.txt_desc2:SetActive(true)
        self.txt_desc2.text = self.arguments.desc2
    else
        self.txt_desc2:SetActive(false)
    end
    --[[
    if self.arguments.PreventShowButtonsOnClose then
        self:PreventShowButtonsOnClose()
    end
    ]]
end

function CommonRewardPanel:refreshUI()
end

function CommonRewardPanel:ShowDragon(reward)
    self.txt_congrats:SetActive(true)
    self.txt_name:SetActive(true)
    self.txt_dragon_product:SetActive(true)
    self.productLimit:SetActive(true)

    local meta = AppServices.Meta:GetMagicalCreateuresConfigById(reward.ItemId)
    self.icon_dragon_attri.sprite = AppServices.ItemIcons:GetSpriteByName(meta.attributeIcon)
    self.txt_name.text = Runtime.Translate(meta.name)

    local product = meta.productivity
    local time = product[2] // 60
    local itmInf = AppServices.Meta:GetItemMeta(product[1])
    self.icon_dragon_product.sprite = AppServices.ItemIcons:GetSpriteByName(itmInf.icon)
    local itemName = AppServices.Meta:GetItemName(product[1])
    self.txt_dragon_product.text =
    Runtime.Translate(
    "ui_dragon_product_minute",
    {time = tostring(time), num = tostring(product[3]), name = itemName}
    )
    if meta.dayProductGetLimit ~= -1 then
        self.productLimit.text =
        Runtime.Translate(
        "ui_dragonProductLimit_text7",
        {num1 = tostring(meta.dayProductGetLimit), num2 = tostring(meta.allProductGetLimit)}
        )
    else
        self.productLimit.text = ""
    end
    --if self.arguments.notHaveDragon then
    --self.newkind:SetActive(true)
    --self.txt_newKind.text = Runtime.Translate("ui_getdragon_newtype")
    --end
    if self.arguments.shouDragonCount then
        self.txt_dragonNum:SetActive(true)
        self.txt_dragonNum.text = "x" .. reward.Amount
    end
    App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_acquire_dragons)
end

--[[
    rewards: {{ItemId,Amount}}
]]
function CommonRewardPanel:InitRewards(rewards)
    self.rewards = rewards
    if not self.arguments.donotSort then
        self:SortRewards()
    end
    local useGrid = self.arguments.useGrid
    for k, v in ipairs(rewards) do
        local reward, item = self:GetRewardInstance(v)
        if useGrid then
            item:SetParent(self.gridRoot, false)
        else
            self.container_items:AddItem(item)
        end
        if v.ItemId and ItemId.IsDragon(v.ItemId) then
            self.dragonRewardItems = self.dragonRewardItems or {}
            table.insert(self.dragonRewardItems, item)
        end
        -- if self.arguments.fadeIn and reward.SetAlpha then
        --     reward:SetAlpha(0)
        -- end
        table.insert(self.flyItems, reward)
    end
    self.go_halo_panel:SetActive(false)
    self.container_buildings.gameObject:SetActive(false)
    self.container_items.transform.anchoredPosition = Vector2(0, 0)
end

function CommonRewardPanel:InitRewardsInSequence(rewards)
    self.rewards = rewards
    if not self.arguments.donotSort then
        self:SortRewards()
    end
    local specialQueue = {}
    local total = #rewards
    for k, v in ipairs(rewards) do
        local reward, item = self:GetRewardInstance(v)
        if self.arguments.useGrid then
            item:SetParent(self.gridRoot, false)
        else
            item:SetParent(self.gridRoot_2, false)
        end
        item.transform.localScale = Vector3.one * 2
        local pos = Vector2(-260 + (k - 1) % 5 * 130, 100 - 150 * math.floor((k - 1) / 5))
        if total < 6 then
            pos.y = 0
        end
        reward:SetPosition(pos)
        reward.canvasGroup.alpha = 0
        if v.special then
            -- local function cbk()
            --     self.specialMask:DOFade(0, 0.3)
            -- end
            -- WaitExtension.SetTimeout(function()
            --     Runtime.InvokeCbk(v.callback, reward, cbk)
            --     self.specialMask:DOFade(0.5, 0.3)
            -- end, (k-1)*0.2)
            table.insert(specialQueue, {item = reward, time = (k - 1) * 0.2, pos = pos})
        else
            item.transform:DOScale(Vector3.one, 0.3):SetDelay((k - 1) * 0.2)
            reward.canvasGroup:DOFade(1, 0.3):SetDelay((k - 1) * 0.2)
        end
        if #specialQueue > 0 then
            local function cbk()
                self.specialMask:DOFade(0, 0.3)
            end
            local count = #specialQueue
            local start = -150 * (count - 1)
            for k, v in ipairs(specialQueue) do
                v.item:SetPosition(Vector2(start + (k - 1) * 300, 42))
            end
            WaitExtension.SetTimeout(
                function()
                    Runtime.InvokeCbk(self.arguments.specialCallback, specialQueue, cbk)
                    self.specialMask:DOFade(0.5, 0.3)
                end,
                specialQueue[1].time
            )
        end
        table.insert(self.flyItems, reward)
    end
    self.specialMask.transform:SetAsLastSibling()
end

function CommonRewardPanel:InitDragonRewardsInSequence(rewards, callbacks)
    self.rewards = rewards
    if not self.arguments.donotSort then
        self:SortRewards()
    end
    local specialQueue = {}
    local total = #rewards
    local showIndex = 1
    local showNext = nil
    local showIcon = function(callback, rewardIndex)
        if Runtime.CSNull(self.gameObject) then
            Runtime.InvokeCbk(callbacks)
            return
        end
        local rewardData = rewards[rewardIndex]
        local reward, item = self:GetRewardInstance(rewardData)
        if self.arguments.useGrid then
            item:SetParent(self.gridRoot, false)
        else
            item:SetParent(self.gridRoot_2, false)
        end
        item.transform.localScale = Vector3.one * 2
        local pos = Vector2(-260 + (rewardIndex - 1) % 5 * 130, 100 - 150 * math.floor((rewardIndex - 1) / 5))
        if total < 6 then
            pos.y = 0
        end
        reward:SetPosition(pos)
        reward.canvasGroup.alpha = 0
        if reward.special then
            table.insert(specialQueue, {item = reward, time = (rewardIndex - 1) * 0.2, pos = pos})
        else
            item.transform:DOScale(Vector3.one, 0.3)--:SetDelay((rewardIndex - 1) * 0.2)
            reward.canvasGroup:DOFade(1, 0.3)--:SetDelay((rewardIndex - 1) * 0.2)
        end
        table.insert(self.flyItems, reward)
        self:SetDelay(callback, 0.2)
    end
    local showDragon = function(rewardIndex)
        if Runtime.CSNull(self.gameObject) then
            Runtime.InvokeCbk(callbacks)
            return
        end
        local rewardData = rewards[rewardIndex]
        local reward, item = self:getDragon(rewardData, true)
        if self.arguments.useGrid then
            item:SetParent(self.gridRoot, false)
        else
            item:SetParent(self.gridRoot_2, false)
        end
        item.transform.localScale = Vector3.one * 2
        local pos = Vector2(-260 + (rewardIndex - 1) % 5 * 130, 100 - 150 * math.floor((rewardIndex - 1) / 5))
        if total < 6 then
            pos.y = 0
        end
        reward:SetPosition(pos)
        if rewards.canvasGroup then
            reward.canvasGroup.alpha = 0
        end
        if reward.special then
            table.insert(specialQueue, {item = reward, time = (rewardIndex - 1) * 0.2, pos = pos})
        else
            item.transform:DOScale(Vector3.one, 0.3)--:SetDelay((rewardIndex - 1) * 0.2)
            reward.canvasGroup:DOFade(1, 0.3)--:SetDelay((rewardIndex - 1) * 0.2)
        end
        table.insert(self.flyItems, reward)

        _, item = self:getDragon(rewardData, false)
        self.container_items:AddItem(item)
        self.dragonRewardItems = self.dragonRewardItems or {}
        table.insert(self.dragonRewardItems, item)
        self.go_halo_panel:SetActive(false)
        self.container_buildings.gameObject:SetActive(false)
        self.container_items.transform.anchoredPosition = Vector2(0, 0)
        self:SetDelay(function()
            if Runtime.CSNull(self.gameObject) then
                Runtime.InvokeCbk(callbacks)
                return
            end
            self.txt_congrats:SetActive(true)
            self.txt_name:SetActive(true)
            self.txt_dragon_product:SetActive(true)
            self.productLimit:SetActive(true)
            self:ShowRewards(function()
                self.btn_nextLayer:SetActive(true)
            end)
        end , 0.4)
    end
    self.hideDragon = function()
        if Runtime.CSNull(self.gameObject) then
            Runtime.InvokeCbk(callbacks)
            return
        end
        local function onScaleEnd()
            if Runtime.CSNull(self.gameObject) then
                Runtime.InvokeCbk(callbacks)
                return
            end
            for _, dragonItem in ipairs(self.dragonRewardItems) do
                Runtime.CSDestroy(dragonItem.gameObject)
            end
            self.dragonRewardItems = {}
            showNext()
        end
        self.btn_nextLayer:SetActive(false)
        self.txt_congrats:SetActive(false)
        self.txt_name:SetActive(false)
        self.txt_dragon_product:SetActive(false)
        self.productLimit:SetActive(false)
        self.mark:SetActive(false)
        GameUtil.DoScale(self.container_items.gameObject, Vector3.zero, 0.2, onScaleEnd)
    end
    showNext = function()
        if showIndex <= #rewards then
            local tIndex = showIndex
            showIndex = showIndex + 1
            if ItemId.IsDragon(rewards[tIndex].ItemId) then
                showDragon(tIndex)
            else
                showIcon(showNext, tIndex)
            end
        else
            Runtime.InvokeCbk(callbacks)
        end
    end
    showNext()

    self.specialMask.transform:SetAsLastSibling()
end

function CommonRewardPanel:SortRewards()
    local priorityCfg = AppServices.Meta:GetRewardAnimPriority()
    table.sort(
        self.rewards,
        function(a, b)
            local priority_a = priorityCfg[a.ItemId] or 999
            local priority_b = priorityCfg[b.ItemId] or 999
            return priority_a < priority_b
        end
    )
end

function CommonRewardPanel:GetRewardInstance(itemInfo)
    local itemId = itemInfo.ItemId or itemInfo.itemId or itemInfo.itemTemplateId or itemInfo[1]
    local itemType2funcs = {
        [ItemId.EType.DRAGON_ENTITY] = CommonRewardPanel.getDragon
    }
    local itemType = AppServices.Meta:GetItemType(itemId)
    local func = itemType2funcs[itemType]
    if func then
        return func(self, itemInfo)
    else
        return self:getNormal(itemInfo)
    end
end

function CommonRewardPanel.getNormal(self, itemInfo)
    RewardItem = RewardItem or require("UI.Components.RewardItem")
    local reward = RewardItem.new()
    local item = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_ITEM)
    reward:InitWithGameObject(item)
    reward:Generate(itemInfo)
    return reward, item
end

function CommonRewardPanel:getDragon(itemInfo, useDragonIcon)
    if useDragonIcon == nil then
        useDragonIcon = self.arguments.useDragonIcon
    end
    if useDragonIcon then
        return CommonRewardPanel.getDragonIcon(itemInfo)
    end
    self.arguments.noHalo = true
    DragonRewardItem = DragonRewardItem or require("UI.Components.DragonRewardItem")
    ---@type DragonRewardItem
    local reward = DragonRewardItem.new()
    local item = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_DRAGON_ITEM)
    reward:InitWithGameObject(item)
    reward:Generate(itemInfo)
    self:ShowDragon(itemInfo)
    self.mark:SetActive(true)
    local dragonConfig = SceneServices.BreedManager:GetCreatureConfig()[tostring(itemInfo.ItemId)]
    self.newFlag:SetActive(AppServices.MagicalCreatures:GetCreaturesCountByType(dragonConfig.type) == 1)
    AppServices.MagicalCreatures.SwitchRareGo(self.gameObject, "mark/rare/bg_rare", dragonConfig.quality)
    self.m_txtRare.text = AppServices.MagicalCreatures.GetDrageonReraText(dragonConfig.quality)
    return reward, item
end

--使用龙图标而非龙模型
function CommonRewardPanel.getDragonIcon(itemInfo)
    RewardItem = RewardItem or require("UI.Components.RewardItem")
    local reward = RewardItem.new()
    local item = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_ITEM)
    reward:InitWithGameObject(item)
    itemInfo.useDragonIcon = true
    reward:Generate(itemInfo)
    if reward.img_icon and Runtime.CSValid(reward.img_icon) then
        reward.img_icon.transform.localScale = Vector3.one * 1.2
    end
    return reward, item
end

function CommonRewardPanel:StartFirework()
    local fireworks
    if not self.arguments.onceFirework then
        fireworks = BResource.InstantiateFromAssetName(CONST.UIEFFECT_ASSETS.FIREWORKS)
    else
        fireworks = BResource.InstantiateFromAssetName(CONST.UIEFFECT_ASSETS.FIREWORK)
    end
    fireworks:SetParent(self.gameObject, false)
    self.go_fireworks = fireworks
    --播放音效时候可能需要等加载完才能播， 如果在加载完回调里面播音效的时候 界面已经关闭了
    --会导致这个音效不能关闭（这个音效是循环的）
    self.stopAudio = false
    if App.audioManager:HasAudioClipDict(CONST.AUDIO.Interface_Celebrate) == false then
        App.audioManager:LoadAudioClips(
            CONST.AUDIO.Interface_Celebrate,
            function()
                if self.stopAudio == false then
                    App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_Celebrate, false, true)
                end
            end
        )
    else
        App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_Celebrate, false, true)
    end
end

function CommonRewardPanel:StopFirework()
    if Runtime.CSValid(self.go_fireworks) then
        self.go_fireworks:SetActive(false)
    end
    self.stopAudio = true
    App.audioManager:StopAudio(CONST.AUDIO.Interface_Celebrate)
end

function CommonRewardPanel:FlyRewards(finishCallback)
    self.go_halo_panel:SetActive(false)
    local total = #self.rewards or 0
    if total == 0 then
        Runtime.InvokeCbk(finishCallback)
        return
    end

    -- local counter = 0
    local flyCount = 0
    local function onFinish()
        --[[counter = counter + 1
        if counter == total then
            if finishCallback then
                finishCallback()
            end
        end--]]
        flyCount = flyCount - 1
        if flyCount == 0 then
            if self.arguments.showTarget then
                Runtime.InvokeCbk(finishCallback)
            end
        end
    end

    local function flyItemCallback(flyObject)
        -- local reward = RewardItem.new()
        -- reward:InitWithGameObject(flyObject)
        -- reward:DoSizeDelta(Vector2(71, 71), 1)
        -- reward:HideGlow()
    end

    for k, v in ipairs(self.rewards) do
        if k <= #self.flyItems then
            local flyItem = self.flyItems[k]
            flyItem.text_count.gameObject:SetActive(false)
            flyItem.img_glow.gameObject:SetActive(false)
            if v.special then
                flyItem.img_icon:DOFade(0, 0.8)
            else
                if ItemId.GetWidget(v.ItemId) then
                    flyCount = flyCount + 1
                    AppServices.FlyAnimation.FlyItem(
                    v.ItemId,
                    flyItem,
                    onFinish,
                    flyItemCallback,
                    nil,
                    self.arguments.showTarget
                    )
                else
                    flyItem.img_icon:DOFade(0, 0.8)
                end
            end
        end
    end
    if not self.arguments.showTarget or flyCount == 0 then
        Runtime.InvokeCbk(finishCallback)
    end
end

function CommonRewardPanel:ShowRewards(finishCallback)
    if not self.arguments.noHalo then
        self.go_halo_panel:SetActive(true)
    end
    local scaleTime = 0.5
    local t, c = 0, 0
    local function onScaleEnd()
        c = c + 1
        if t ~= c then
            return
        end
        Runtime.InvokeCbk(finishCallback)
    end
    t = t + 1
    GameUtil.DoScale(self.container_items.gameObject, Vector3.one, scaleTime, onScaleEnd)
    -- GameUtil.DoScale(self.gridRoot, Vector3.one, scaleTime, onScaleEnd)
    if self.arguments.fadeIn then
        local fadeTime = 0.2
        local interval = 0.2
        for index, value in ipairs(self.flyItems) do
            if value.FadeIn then
                value:FadeIn(fadeTime, interval * (index - 1))
            end
        end
    end
end

return CommonRewardPanel
