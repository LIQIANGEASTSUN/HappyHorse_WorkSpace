local DragonFishingCityView = {}

---@param rootView MainCity
function DragonFishingCityView:Create(rootView)
    self.rootView = rootView
    self.layout = rootView.layout
    return self
end

function DragonFishingCityView:Init()
    -- local HeartItem = require "UI.Components.HeartItem"
    -- local heartItem = HeartItem:Create()
    -- heartItem:SetParent(self.layout:Node(), false)
    -- heartItem.gameObject:SetActive(false)
    -- self.rootView:AddWidget(CONST.MAINUI.ICONS.EnergyIcon, heartItem)

end

function DragonFishingCityView:BeforeUnload()

end

function DragonFishingCityView:ShowBottomIcons(isFirstTime)
    for k, v in pairs(self.rootView.widgets) do
        if type(v.OnEvent_ShowBottomIcons) == "function" then
            Runtime.InvokeCbk(v.OnEvent_ShowBottomIcons, v, isFirstTime)
        end
    end
end

local UIIconType2HideType = {
    [CONST.MAINUI.ICONS.BagBtn] = TopIconHideType.stayBagIcon
}
function DragonFishingCityView:HideBottomIcons(instant, hideType)
    for k, v in pairs(self.rootView.widgets) do
        if
            (UIIconType2HideType[k] == nil or hideType == nil or hideType & UIIconType2HideType[k] == 0) and
                type(v.OnEvent_HideBottomIcons) == "function"
         then
            Runtime.InvokeCbk(v.OnEvent_HideBottomIcons, v, instant)
        end
    end
end

function DragonFishingCityView:Destroy()
end

return DragonFishingCityView
