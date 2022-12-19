local RenderMode = CS.UnityEngine.RenderMode

---@class SceneTextTip
local SceneTextTip = {
    cacheTips = {},
    usingTips = {},
    init = false
}

function SceneTextTip.Destroy()
    self:OnDestroy()
end

function SceneTextTip:Init()
    if Runtime.CSNull(self.gameObject) then
        self.initializing = nil
    end
    if self.initializing then
        return
    end
    self.initializing = true

    local onLoaded = function(sender)
        self.init = true
        self.gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_Scene_Text_Tip_Panel)
        self.gameObject:SetActive(true)
        self.gameObject.transform.forward = Camera.main.transform.forward
        local canvas = self.gameObject:GetComponent(typeof(Canvas))
        GameUtil.SetCanvasRenderMode(canvas, RenderMode.WorldSpace)

        self.tipGo = self.gameObject:FindGameObject("Tip")
        self.tipGo:SetActive(false)
        if self.cacheDatas then
            for _, cache in pairs(self.cacheDatas) do
                self:Show(cache.txt, cache.position)
            end
            self.cacheDatas = nil
        end
    end

    App.uiAssetsManager:LoadAssets({CONST.ASSETS.G_UI_Scene_Text_Tip_Panel}, onLoaded)
end

---@param text string
---@param float_duration number default is 1
---@param fade_duration number default is 0.45
function SceneTextTip:Show(text, position)
    if string.isEmpty(text) or not position then
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
                position = position
            }
        )

        self:Init()
        return
    end
    local tip = self:Get(text)
    if not tip then
        return
    end

    tip:SetPosition(position)
    tip:Show(text, 0.5, 1)
end

function SceneTextTip:Get(txt)
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
    tip.SetPosition = function(tip, position)
        tip.gameObject:SetPosition(position)
    end
    tip.Show = function(tip, txt_, float_duration, fade_duration)
        tip.inUse = true
        tip.label.text = txt_
        local cg = tip.gameObject:GetComponent(typeof(CanvasGroup))
        cg.alpha = 1

        tip.gameObject:SetActive(true)
        local tweenFade = GameUtil.DoFade(tip.gameObject, 0, fade_duration)
        tweenFade:SetDelay(float_duration)
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

function SceneTextTip:OnDestroy()
    Runtime.CSDestroy(self.gameObject)
    self.gameObject = nil
end

return SceneTextTip
