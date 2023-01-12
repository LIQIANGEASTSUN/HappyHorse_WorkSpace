local ItemGiftTip = class(PanelItemBase, "ItemGiftTip")

function ItemGiftTip.Create(parentPanel, assetPath)
    local instance = ItemGiftTip.new(parentPanel)
    local go = BResource.InstantiateFromAssetName(assetPath)
    instance:InitWithGameObject(go)
    return instance
end

function ItemGiftTip:InitWithGameObject(go)
    self.gameObject = go
    self.go_bg = find_component(go, "img_bg")
    self.img_node = find_component(go, "img_bg/img_node")
    self.btn_topMask = find_component(go, "btn_topMask", Button)
    Util.UGUI_AddButtonListener(
        self.btn_topMask,
        function()
            self:setActive(false)
        end
    )
    self.gameObject.transform:SetParent(self.parentPanel.gameObject.transform, false)
end

function ItemGiftTip:ctor(parentPanel)
    self.parentPanel = parentPanel
end

function ItemGiftTip:SetData(items, parentGameObject, offsetHeight,noMask)
    -- self.gameObject.transform.position = Vector3(100000, 0, 0)
    local nodes = self:CopyComponent(self.img_node, self.go_bg, #items)
    for i, go in ipairs(nodes) do
        local img_node = go:GetComponent(typeof(Image))
        local label = find_component(go, "Text", Text)
        local item = items[i]
        local sprite = AppServices.ItemIcons:GetSprite(item[1] or item.itemId)
        img_node.sprite = sprite
        label.text = (item[2] or item.count)
    end
    if noMask then
        self:SetComponentVisible(self.btn_topMask, false)
    else
        self:SetComponentVisible(self.btn_topMask, true)
    end
    local pposition = parentGameObject:GetPosition()
    local startPos = GOUtil.WorldPositionToLocal(self.parentPanel.gameObject, pposition) + Vector3(0, offsetHeight, 0)
    self.gameObject:SetLocalPosition(startPos)
    local centerPos = GOUtil.WorldPositionToLocal(self.gameObject, App.scene.panelLayer.gameObject.transform.position)
    self.btn_topMask.transform:SetLocalPosition(centerPos)
    self:setActive(true)
end

return ItemGiftTip
