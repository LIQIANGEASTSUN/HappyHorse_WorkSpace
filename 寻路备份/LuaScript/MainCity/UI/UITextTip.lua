local RenderMode = CS.UnityEngine.RenderMode

---@class UITextTip
local UITextTip = {
    cacheTips = {},
    usingTips = {},
    init = false
}

function UITextTip.Destroy()
    self:OnDestroy()
end

function UITextTip:Init()
    if Runtime.CSNull(self.gameObject) then
        self.initializing = nil
    end
    if self.initializing then
        return
    end
    self.initializing = true

    local onLoaded = function(sender)
        self.init = true
        self.gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_Text_Tip_Panel)
        self.gameObject:SetActive(true)
        local canvas = self.gameObject:GetComponent(typeof(Canvas))
        GameUtil.SetCanvasRenderMode(canvas, RenderMode.ScreenSpaceCamera)

        self.tipGo = self.gameObject:FindGameObject("Tip")
        self.tipGo:SetActive(false)
        if self.cacheDatas then
            for _, cache in pairs(self.cacheDatas) do
                self:Show(cache.txt, cache.float_duration, cache.fade_duration)
            end
            self.cacheDatas = nil
        end
    end

    App.uiAssetsManager:LoadAssets({CONST.ASSETS.G_UI_Text_Tip_Panel}, onLoaded)
end

---@param text string
---@param float_duration number default is 1
---@param fade_duration number default is 0.45
--[[function UITextTip:Show(text, float_duration, fade_duration)
    if string.isEmpty(text) then
        return
    end

    if Runtime.CSNull(self.gameObject) then
        self.init = false
    end

    if not self.init then
        self.cacheDatas = self.cacheDatas or {}
        table.insert(
            self.cacheDatas,
            {
                txt = text,
                float_duration = float_duration,
                fade_duration = fade_duration
            }
        )
        self:Init()
        return
    end
    local tip = self:Get(text)
    if not tip then
        return
    end

    --float_duration = float_duration or 0.5
    --float_duration = float_duration + 1.5   --这么写是为了兼容之前有的接口设置过时间，这样可以等量增加时间
    float_duration = 2
    fade_duration = fade_duration or 1
    tip:Show(text, float_duration, fade_duration)
end--]]

function UITextTip:Show(text)
    UITool.ShowContentTipAni(text)
end

function UITextTip:Get(txt)
    for _, tip in pairs(self.cacheTips) do
        if Runtime.CSNull(tip.gameObject) then
            table.remove(self.cacheTips, _)
        else
            if tip:IsSame(txt) then
                return
            end

            if not tip.inUse then
                return tip
            end
        end
    end

    local go = GameObject.Instantiate(self.tipGo)
    go:SetParent(self.tipGo:GetParent(), false)
    local text = find_component(go, "bg/Text", Text)
    local tip = {
        gameObject = go,
        label = text,
        inUse = false
    }
    tip.Show = function(tip, txt_, float_duration, fade_duration)
        local fadeIn_duration = 0.2
        local fadeOut_duration = 0.3
        tip.inUse = true
        tip.label.text = txt_
        local cg = tip.gameObject:GetComponent(typeof(CanvasGroup))
        cg.alpha = 0

        tip.gameObject.transform.anchoredPosition = (Vector2(0, -30)) --临时的 等动画
        tip.gameObject:SetActive(true)

        tip.gameObject.transform:DOAnchorPos(Vector2(0, 30), float_duration)
        --tweenMove:SetDelay(float_duration)
        GameUtil.DoFade(tip.gameObject, 1, fadeIn_duration)

        local tweenFade = GameUtil.DoFade(tip.gameObject, 0, fadeOut_duration)
        tweenFade:SetDelay(float_duration - fadeOut_duration)
        tweenFade.onComplete = function()
            tip.inUse = false
            tip.gameObject:SetActive(false)
        end
    end
    tip.IsSame = function(tip, txt_)
        if tip.inUse then
            return tip.label.text == txt_
        end
    end

    table.insert(self.cacheTips, tip)
    return tip
end

function UITextTip:OnDestroy()
    Runtime.CSDestroy(self.gameObject)
    self.gameObject = nil
end

return UITextTip
