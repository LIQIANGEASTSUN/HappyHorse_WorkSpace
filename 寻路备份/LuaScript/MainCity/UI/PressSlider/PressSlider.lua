---@type PressSlider
local PressSlider = class(nil, "PressSlider")

function PressSlider:ctor()
    self.gameObject = nil
    self.slider = nil
end

---@param value number @按压进度[0, 1]
function PressSlider:Show(position, value)
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetPosition(position)
        self.gameObject:SetActive(true)
        self.slider.value = value
    end
end

function PressSlider:Hide()
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetActive(false)
    end
end

function PressSlider:Init()
    local canvas = App.scene.sceneCanvas
    if Runtime.CSValid(canvas) then
        self:Instantiate(canvas)
        registerMediator("MainCity.UI.PressSlider.PressSliderMediator", self)
    else
        console.error(nil, "No canvas found in scene!!!") --@DEL
    end
end

function PressSlider:Instantiate(parent)
    local go = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_PRESS_SLIDER)
    self.gameObject = go
    self.gameObject.transform:SetParent(parent.transform, false)
    self.gameObject.transform:SetLocalScale(50, 50, 50)

    self.slider = self.gameObject:GetComponent(typeof(Slider))
    self.slider.maxValue = 1

    self:Hide()
end

function PressSlider:Destroy()
    removeMediator("MainCity.UI.PressSlider.PressSliderMediator")
    Runtime.CSDestroy(self.gameObject)
    self.gameObject = nil
end

return PressSlider
