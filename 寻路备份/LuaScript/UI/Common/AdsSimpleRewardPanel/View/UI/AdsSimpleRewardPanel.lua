--insertWidgetsBegin
--    go_ItemContaniner
--insertWidgetsEnd
local RewardItem = require("UI.Components.RewardItem")
--insertRequire
local _AdsSimpleRewardPanelBase = require "UI.Common.AdsSimpleRewardPanel.View.UI.Base._AdsSimpleRewardPanelBase"

---@class AdsSimpleRewardPanel:_AdsSimpleRewardPanelBase
local AdsSimpleRewardPanel = class(_AdsSimpleRewardPanelBase)

function AdsSimpleRewardPanel:ctor()
    ---@type RewardItem[]
    self.flyItems = {}
end

function AdsSimpleRewardPanel:onAfterBindView()
    local curveAssetPath = "Prefab/UI/Common/Buildin/RewardItem/RewardItemScaleCurve.asset"
    local function onLoaded()
        self.curveAsset = App.uiAssetsManager:GetAsset(curveAssetPath)
    end
    App.uiAssetsManager:LoadAssets({curveAssetPath}, onLoaded)

    self.container_items:SetSpacing(25)
    Util.UGUI_AddButtonListener(
        self.getBtn,
        function()
            self:OnGet()
        end
    )

    Util.UGUI_AddButtonListener(
        self.adsBtn,
        function()
            self:OnAds()
        end
    )
    self.text_title.text = self.arguments.titleText or ""
    self.text_tip.text = self.arguments.descText or ""
end

function AdsSimpleRewardPanel:OnGetCallback()
    self:FlyRewards()
end

function AdsSimpleRewardPanel:OnGet()
    self.getBtn:SetActive(false)
    self.adsBtn:SetActive(false)
    AppServices.AdsManager:RecordLastPlayTime(self.arguments.adsType)
    Runtime.InvokeCbk(
        self.arguments.getCallback,
        function(result)
            if result then
                self:OnGetCallback()
            else
                self.getBtn:SetActive(true)
                self:ShowAdsBtn()
            end
        end
    )
end

function AdsSimpleRewardPanel:OnAdsCallback()
    local showDoubleFinished = function()
        self:FlyRewards()
    end
    self:ShowDoubleReward(showDoubleFinished)
end

function AdsSimpleRewardPanel:ShowAdsBtn()
    local showAds = AppServices.AdsManager:CheckActiveById(self.arguments.adsType)
    if showAds then
        DcDelegates.Ads:LogEntryShow(self.arguments.adsType)
    end
    self.adsBtn:SetActive(true and showAds)
end

function AdsSimpleRewardPanel:OnAds()
    self.getBtn:SetActive(false)
    self.adsBtn:SetActive(false)

    local function playAdsCallback(result)
        if result then
            AppServices.AdsManager:ClientWatchAdsById(self.arguments.adsType)
            self.arguments.adsCallback(
                function(_result)
                    if _result then
                        self:OnAdsCallback()
                    else
                        self.getBtn:SetActive(true)
                        self:ShowAdsBtn()
                    end
                end
            )
        else
            self.getBtn:SetActive(true)
            self:ShowAdsBtn()
        end
    end

    AppServices.AdsManager:PlayAds(self.arguments.adsType, nil, playAdsCallback)
    DcDelegates.Ads:LogEntryClick(self.arguments.adsType)
end

function AdsSimpleRewardPanel:InitRewards(rewards)
    self.rewards = rewards
    self:SortRewards()
    for k, v in ipairs(rewards) do
        local reward = RewardItem.new()
        local item = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_ITEM)
        reward:InitWithGameObject(item)
        reward:Generate(v)
        reward.transform.localScale = Vector3.zero
        self.container_items:AddItem(item)
        table.insert(self.flyItems, reward)
    end
    self.container_items.transform.anchoredPosition = Vector2(0, 0)
end

function AdsSimpleRewardPanel:SortRewards()
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

function AdsSimpleRewardPanel:ShowDoubleReward(callback)
    local scaleTime = 0.8
    local ease = self.curveAsset and self.curveAsset.curve or Ease.Linear
    for index, value in ipairs(self.flyItems) do
        self.rewards[index].Amount = self.rewards[index].Amount * 2
        self.rewards[index].text = nil
        value:Generate(self.rewards[index])
        value.transform.localScale = Vector3.zero
        value.transform:DOScale(1, scaleTime):SetEase(ease)
    end

    self.gameObject:SetTimeOut(callback, scaleTime + 1)
end

function AdsSimpleRewardPanel:ShowRewards()
    local scaleTime = 0.5
    local ease = self.curveAsset and self.curveAsset.curve or Ease.Linear
    for index, value in ipairs(self.flyItems) do
        value.transform:DOScale(1, scaleTime):SetEase(ease)
    end

    self.gameObject:SetTimeOut(
        function()
            if self.arguments.directGet then
                self:OnGet()
            else
                self.getBtn:SetActive(true)
                self:ShowAdsBtn()
            end
        end,
        scaleTime + 0.1
    )
end

function AdsSimpleRewardPanel:FlyRewards()
    -- local total = #self.rewards
    -- local counter = 0
    -- local function onFinish()
    -- counter = counter + 1
    -- if counter == total then
    --     PanelManager.closePanel(self.panelVO)
    -- end
    -- end

    -- local function flyItemCallback(flyObject)
    -- end

    local flyTime = 0.5
    for k, v in ipairs(self.rewards) do
        local flyItem = self.flyItems[k]

        flyItem.transform:DOScale(0.45, flyTime)
        if flyItem.trail_jinbi and (v.ItemId == ItemId.COIN or v.ItemId == ItemId.EXP) then
            flyItem.trail_jinbi:SetActive(true)
        elseif flyItem.trail_tili and (v.ItemId == ItemId.ENERGY or v.ItemId == ItemId.DIAMOND) then
            flyItem.trail_tili:SetActive(true)
        end
        AppServices.FlyAnimation.FlyItem(v.ItemId, flyItem, nil, nil, flyTime)
    end
    PanelManager.closePanel(self.panelVO)
end

function AdsSimpleRewardPanel:refreshUI()
end

function AdsSimpleRewardPanel:StartFirework()
    local fireworks = BResource.InstantiateFromAssetName(CONST.UIEFFECT_ASSETS.FIREWORKS)
    fireworks:SetParent(self.effectRoot, false)
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

function AdsSimpleRewardPanel:StopFirework()
    if Runtime.CSValid(self.go_fireworks) then
        self.go_fireworks:SetActive(false)
    end
    self.stopAudio = true
    App.audioManager:StopAudio(CONST.AUDIO.Interface_Celebrate)
end

return AdsSimpleRewardPanel
