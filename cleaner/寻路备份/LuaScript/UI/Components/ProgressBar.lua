---@class ProgressBar
local ProgressBar = class(LuaUiBase, "ProgressBar")

local Image = CS.UnityEngine.UI.Image


local BarMode = 1
local ClipMode = 2
function ProgressBar:ctor()
    self.mode = BarMode
end

function ProgressBar:CreateWithGameObject(gameObject)
    local instance = ProgressBar.new()
    instance:InitFromGameObject(gameObject)
    return instance
end

function ProgressBar:InitFromGameObject(gameObject)
    LuaUiBase.InitFromGameObject(self, gameObject)
    self.progressHandler = gameObject:GetOrAddComponent(typeof(ProgressHandler))
    self.bgImage = self.gameObject:GetComponent(typeof(Image))
    self.scrollbar = self.gameObject:GetComponent(typeof(Scrollbar))
    self.slidingAreaHandle = self.gameObject:FindGameObject("Sliding Area/Handle"):GetComponent(typeof(Image))
    self:SetPercentage(0)
end

function ProgressBar:SetBarMode()
    self.mode = BarMode
    self.slidingAreaHandle.type = Image.Type.Sliced
end

function ProgressBar:SetClipMode()
    self.mode = ClipMode
    self.slidingAreaHandle.type = Image.Type.Filled
end

function ProgressBar:SetPercentage(value)
    self.currentPercentage = value
    if self.mode == BarMode then
        self.scrollbar.size = value / 100
    else
        self.slidingAreaHandle.fillAmount = value / 100
    end
end

function ProgressBar:AnimateToPercentage(value, callback)

    self.progressHandler:AnimateToPercent(self.currentPercentage/100, value/100, callback)
end

function ProgressBar:GetLocalPositionByPercentage(percentage)
    local rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
    local rect = rectTransform.rect
    --print(rect.min.x, rect.width, rect.min.y, rect.height) --@DEL
    return Vector2(rect.width * (percentage/100), 0)
end

function ProgressBar:DisposeLua()
    LuaUiBase.DisposeLua(self)
    print('ProgressBar:DisposeLua()') --@DEL
end

return ProgressBar