---@class SellItem
local SellItem = class(nil, "SellItem")

function SellItem:ctor(go)
    self.alive = true
    self:RefreshUI(go)
end

function SellItem:SetData(data)
    self.data = data
    self.itemMeta = data.meta
    self.maxCount = AppServices.User:GetItemAmount(data.meta.sn)
    self.recycleItemId = self.itemMeta.recycleItem[1][1]
    self.recycleItemPrice = self.itemMeta.recycleItem[1][2]
    if Runtime.CSValid(self.sellSlider) then
        self.sellSlider.wholeNumbers = true
        self.sellSlider.maxValue = self.maxCount
        self.sellSlider.minValue = 0
        self.sellSlider.value = self.data.select
    end
    self.sellIcon.sprite = AppServices.ItemIcons:GetSprite(self.itemMeta.sn)
    self.rewardIcon.sprite = AppServices.ItemIcons:GetSprite(self.recycleItemId)
end

function SellItem:RefreshUI(gameObject)
    self.gameObject = gameObject
    self.txtSellCount = find_component(gameObject, "txtSellCount", Text)

    self.sellIcon = find_component(gameObject, "sellIcon", Image)

    self.rewardIcon = find_component(gameObject, "rewardIcon", Image)
    self.txtGetCount = find_component(gameObject, "txtGetCount", Text)
    self.btnSell = find_component(gameObject, "SellButton")

    Util.UGUI_AddButtonListener(self.btnSell, self.ClickSell, self)

    local function onValueChange(value)
        if not self.alive then
            return
        end
        self:OnSliderValue(value)
    end
    self.sellSlider = find_component(gameObject, "Slider", Slider)
    self.sellSlider.onValueChanged:AddListener(onValueChange)
end

function SellItem:ResetSell()
    if Runtime.CSValid(self.sellSlider) then
        self.maxCount = self.maxCount - self.data.select
        self.sellSlider.maxValue = self.maxCount
        self.sellSlider.value = 0
    end
end

function SellItem:OnSliderValue(value)
    self.data.select = value
    self.txtSellCount.text = math.floor(self.data.select)
    self.txtGetCount.text = math.floor(self.data.select * self.recycleItemPrice)
end

function SellItem:ClickSell()
    local count = self.data.select
    if count <= 0 then
        return
    end
    local info = {items = {{key = self.itemMeta.sn, value = count}}}
    AppServices.Net:Send(MsgMap.CSRecycle, info)
    self:ResetSell()
end

function SellItem:Destroy()
    self.alive = nil
end
return SellItem
