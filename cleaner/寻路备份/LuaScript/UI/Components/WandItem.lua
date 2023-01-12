---@class WandItem:LuaUiBase
local WandItem = class(LuaUiBase)

function WandItem:InitWithGameObject(go)
    self.gameObject = go
    self.text = self.gameObject:FindComponentInChildren("Text", typeof(Text))
end

function WandItem:SetText(text)
    self.text.text = text
end

-- function WandItem:DoSizeDelta(toSize, duration)
--     local rtf_icon = self.img_icon:GetComponent(typeof(RectTransform))
--     local rtf_glow = self.img_glow:GetComponent(typeof(RectTransform))

--     local radio = rtf_icon.sizeDelta / toSize
--     local newGlowSize = Vector2(rtf_glow.sizeDelta.x / radio.x, rtf_glow.sizeDelta.y / radio.y)
--     GameUtil.DoSizeDelta(rtf_icon, toSize, duration):SetEase(Ease.InQuart)
--     GameUtil.DoSizeDelta(rtf_glow, newGlowSize, duration):SetEase(Ease.InQuart)
-- end
-- function WandItem:DoScale(toSize, duration)
--     local tween = GameUtil.DoScale(self.gameObject.transform, toSize, duration)
--     tween:SetEase(Ease.InQuart)
--     return tween
-- end

function WandItem:HideText()
    self.text:SetActive(false)
end
function WandItem:ShowText()
    self.text:SetActive(true)
end

function WandItem:GetMainIconGameObject()
    return self.gameObject
end

function WandItem:Destroy()
    Runtime.CSDestroy(self.gameObject)
    self.gameObject = nil
    self.text = nil
end

return WandItem
