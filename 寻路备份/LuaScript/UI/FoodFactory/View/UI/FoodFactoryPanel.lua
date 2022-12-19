--insertWidgetsBegin
--insertWidgetsEnd

--insertRequire
local _FoodFactoryPanelBase = require "UI.FoodFactory.View.UI.Base._FoodFactoryPanelBase"

---@type FoodFactoryProduct
local FoodFactoryProduct = require "UI.FoodFactory.View.UI.FoodFactoryProduct"
---@type FoodFactoryUpLevelPanel
local FoodFactoryUpLevelPanel = require "UI.FoodFactory.View.UI.FoodFactoryUpLevelPanel"

---@class FoodFactoryPanel:_FoodFactoryPanelBase
local FoodFactoryPanel = class(_FoodFactoryPanelBase)

function FoodFactoryPanel:ctor()
    self.arguments = nil
end

function FoodFactoryPanel:onAfterBindView()

end

function FoodFactoryPanel:SetArguments(arguments)
    self.arguments = arguments
    -- local arguments = {id = self.id, sn = self.data.meta.sn}
end

function FoodFactoryPanel:refreshUI()
    local data = {index = 1}
    self:TypeClick(data)
end

function FoodFactoryPanel:TypeClick(data)
    for index, item in pairs(self.typeUI) do
        local select = data.index == index
        item.select.gameObject:SetActive(select)
        item.unSelect.gameObject:SetActive(not select)
    end

    self:RefreshType(data.index)
end

function FoodFactoryPanel:RefreshType(index)
    self.productTr.gameObject:SetActive(index == 1)
	self.upLevelTr.gameObject:SetActive(index == 2)

    if index == 1 then
        FoodFactoryProduct:refresh(self.productTr, self.arguments)
    elseif index == 2 then
        FoodFactoryUpLevelPanel:refresh(self.upLevelTr, self.arguments)
    end
end

function FoodFactoryPanel:Hide()
    FoodFactoryProduct:Hide()
    FoodFactoryUpLevelPanel:Hide()
end

return FoodFactoryPanel
