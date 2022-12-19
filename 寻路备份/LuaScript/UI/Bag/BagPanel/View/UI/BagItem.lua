local BagItem = {}

function BagItem.Create()
    local go = BResource.InstantiateFromAssetName("Prefab/UI/Bag/item.prefab")
    local itm = {}
    setmetatable(itm, {__index = BagItem})
    itm:Bind(go)
    return itm
end

function BagItem:Bind(go)
    self.gameObject = go
    self.transform = go.transform
    local bgNormal = find_component(go, "bgNormal")
    self.bgTrans = bgNormal.transform
    self.imgIcon = find_component(bgNormal, "imgIcon", Image)
    self.txtCount = find_component(bgNormal, "txtCount", Text)

    Util.UGUI_AddButtonListener(bgNormal, function()
        self:OnClick()
    end)
end

function BagItem:SetData(dt)
    self.data = dt
    local spr = AppServices.ItemIcons:GetSprite(dt.itemId)
    UITool.AdaptImage(self.imgIcon, spr, 160)
    self.txtCount.text = dt.count
end

function BagItem:OnClick()
    sendNotification(BagPanelNotificationEnum.OpenTip, {config = self.data.config, pos = self.bgTrans.position})
end

return BagItem