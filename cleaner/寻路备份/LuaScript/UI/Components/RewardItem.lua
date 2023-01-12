local HiddenTimeTextItems = {
    ["100023"] = true, --无限精力3小时
    ["100058"] = true, --无限精力15分
    ["100059"] = true, --无限精力30分
    ["100060"] = true, --无限精力1小时
    ["100063"] = true --无限精力120分
}

---@class RewardItem:LuaUiBase
local RewardItem = class(LuaUiBase, "RewardItem")

function RewardItem:InitWithGameObject(go)
    self.gameObject = go
    self.transform = go.transform
    self.img_icon = go:FindComponentInChildren("img_icon", typeof(MaskableGraphic))
    self.img_glow = go:FindComponentInChildren("img_glow", typeof(Image))
    self.text_count = go:FindComponentInChildren("text_count", typeof(Text))
    self.text_rate = go:FindComponentInChildren("text_rate", typeof(Text))
    self.trail_jinbi = find_component(go, "trail_jinbi")
    self.trail_tili = find_component(go, "trail_tili")
    self.trail_3 = find_component(go, "trail_3")
    self.canvasGroup = find_component(go, "", CanvasGroup)
    self.effect_gold = find_component(go, "effect_gold", null, true)
    self.effect_blue = find_component(go, "effect_blue", null, true)
    self.effect_purple = find_component(go, "effect_purple", null, true)
end

function RewardItem:FadeIn(time, delay)
    self.canvasGroup.alpha = 0
    time = time or 0.5
    delay = delay or 0
    local tweener = GameUtil.DoFadeCanvasGroup(self.gameObject, 1, time)
    tweener:SetDelay(delay)
end

function RewardItem:SetAlpha(alpha)
    self.canvasGroup.alpha = alpha
end

function RewardItem:SetPosition(pos)
    self.transform.anchoredPosition = pos
end

function RewardItem:SetGlow(sprite)
    if sprite then
        self.img_glow.sprite = sprite
        self.img_glow.enabled = true
    else
        self.img_glow.enabled = false
    end
end

function RewardItem:SetText(text)
    self.text_count.text = text
end

function RewardItem:SetSizeDelta(newSize)
    local rtf_icon = self.img_icon:GetComponent(typeof(RectTransform))
    local rtf_glow = self.img_glow:GetComponent(typeof(RectTransform))
    local radio = rtf_icon.sizeDelta / newSize
    rtf_icon.sizeDelta = newSize
    rtf_glow.sizeDelta = Vector2(rtf_glow.sizeDelta.x / radio.x, rtf_glow.sizeDelta.y / radio.y)
end

function RewardItem:DoSizeDelta(toSize, duration)
    local rtf_icon = self.img_icon:GetComponent(typeof(RectTransform))
    local rtf_glow = self.img_glow:GetComponent(typeof(RectTransform))

    local radio = rtf_icon.sizeDelta / toSize
    local newGlowSize = Vector2(rtf_glow.sizeDelta.x / radio.x, rtf_glow.sizeDelta.y / radio.y)
    GameUtil.DoSizeDelta(rtf_icon, toSize, duration):SetEase(Ease.InQuart)
    GameUtil.DoSizeDelta(rtf_glow, newGlowSize, duration):SetEase(Ease.InQuart)
end

function RewardItem:DoScale(toSize, duration)
    local tween = GameUtil.DoScale(self.gameObject.transform, toSize, duration)
    tween:SetEase(Ease.InQuart)
    return tween
end

function RewardItem:ShowGlow(duration, finishCallback)
    if self.img_glow.enabled then
        self.img_glow:SetActive(true)
        local tween = GameUtil.DoFade(self.img_glow, 1, duration)
        tween:OnComplete(
            function()
                Runtime.InvokeCbk(finishCallback)
            end
        )
    end
end

function RewardItem:HideGlow()
    local tween = GameUtil.DoFade(self.img_glow, 0, 0.5)
    tween:OnComplete(
        function()
            self.img_glow:SetActive(false)
        end
    )
end

function RewardItem:HideText()
    self.text_count:SetActive(false)
end

function RewardItem:ShowText()
    self.text_count:SetActive(true)
end

function RewardItem:GetFlyObject()
    return self.img_icon.gameObject
end

function RewardItem:GetMainIconGameObject()
    return self.img_icon.gameObject
end

function RewardItem:DontShowTimeText(id)
    return HiddenTimeTextItems[id]
end

function RewardItem:Generate(itemInfo)
    self.itemInfo = itemInfo
    self.target = itemInfo.target
    -- 绘制icon
    if itemInfo.IsCreature then
        local cf = SceneServices.BreedManager:GetCreatureConfig()[itemInfo.ItemId]
        local path = string.format("Prefab/MagicalCreatures/%s.prefab", cf.model)
        local function onLoaded()
            if Runtime.CSNull(self.gameObject) then
                return
            end
            local go = BResource.InstantiateFromAssetName(path)
            if go and Runtime.CSValid(go) then
                go:SetParent(self.gameObject.transform, false)
                local trans = go.transform:Find("render")
                trans.localScale = Vector3(160, 160, 160)
                trans.localEulerAngles = Vector3(0, 180, 0)
                trans.localPosition = Vector3(0, -45, -18)
                local childCount = trans.childCount
                for i = 0, childCount - 1 do
                    local child = trans:GetChild(i)
                    child.gameObject.layer = CS.UnityEngine.LayerMask.NameToLayer("UI")
                end
            end
            App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_acquire_dragons)
        end
        self.img_icon.gameObject:SetActive(false)
        App.uiAssetsManager:LoadAssets({path}, onLoaded)
    elseif itemInfo.FlyObj then
        self.transform.position = itemInfo.FlyObj.transform.position
        itemInfo.FlyObj:SetParent(self.gameObject, false)
        itemInfo.FlyObj:SetActive(true)
        self.img_icon.gameObject:SetActive(false)
    elseif itemInfo.useDragonIcon then
        local spriteName = AppServices.Meta:GetItemIcon(itemInfo.ItemId)
        self.img_icon = AppServices.ItemIcons:SetDragonIcon(self.img_icon, spriteName)
    else
        self.img_icon.gameObject:SetActive(true)
        self.img_icon.sprite = AppServices.ItemIcons:GetSprite(itemInfo.ItemId)
    end

    -- 绘制背景光
    if itemInfo.ItemId then
        local glowName = AppServices.Meta:GetItemIcon(itemInfo.ItemId) .. "_glow"
        local sprite_glow = AppServices.ItemIcons.itemAtlas:GetSprite(glowName)
        self:SetGlow(sprite_glow)
        --设置背景dotween
        self:ShowGlow(itemInfo.glowDuration or 0.5)
    end
    ---龙基因背光
    if self.effect_gold ~= nil and self.effect_blue ~= nil and self.effect_purple ~= nil then
        self.effect_gold:SetActive(false)
        self.effect_blue:SetActive(false)
        self.effect_purple:SetActive(false)
        if itemInfo.ItemId then
            local itemMeta = AppServices.Meta:GetItemMeta(itemInfo.ItemId)
            if itemMeta.type == 30 then
                local dragonId = tostring(itemMeta.funcParam[1])
                local dragonConfig = SceneServices.BreedManager:GetCreatureConfig()[dragonId]
                self.effect_gold:SetActive(dragonConfig.quality == 4)
                self.effect_blue:SetActive(dragonConfig.quality == 2)
                self.effect_purple:SetActive(dragonConfig.quality == 3)
            elseif itemMeta.type == ItemId.EType.DRAGON_ENTITY then
                local dragonConfig = SceneServices.BreedManager:GetCreatureConfig()[itemInfo.ItemId]
                self.effect_gold:SetActive(dragonConfig.quality == 4)
                self.effect_blue:SetActive(dragonConfig.quality == 2)
                self.effect_purple:SetActive(dragonConfig.quality == 3)
            end
        end
    end

    -- 显示文本
    if not itemInfo.text then
        if itemInfo.ItemId and ItemId.IsEnergyBuff(itemInfo.ItemId) then
            if self:DontShowTimeText(itemInfo.ItemId) then
                -- 不显示时长, 改为显示数量
                itemInfo.text = "x" .. itemInfo.Amount
            else
                itemInfo.text = ItemId.GetEnergyBuffTimeText(itemInfo.ItemId)
            end
        elseif itemInfo.Amount then
            itemInfo.text = "x" .. itemInfo.Amount
        end
    end
    self:SetText(itemInfo.text)
    if itemInfo.rateText then
        self.text_rate.gameObject:SetActive(true)
        self.text_rate.text = itemInfo.rateText
    end
end

function RewardItem:BeginFly()
    self.text_count.gameObject:SetActive(false)
    self.img_glow.gameObject:SetActive(false)
end

function RewardItem:Destroy()
    Runtime.CSDestroy(self.gameObject)
    self.gameObject = nil
end

return RewardItem
