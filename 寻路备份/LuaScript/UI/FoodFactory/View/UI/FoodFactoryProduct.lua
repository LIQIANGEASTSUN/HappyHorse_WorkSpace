---@class FoodFactoryProduct
local FoodFactoryProduct = {}

function FoodFactoryProduct:refresh(transform, arguments)
    self.arguments = arguments

    self:GetUI(transform)
    self:refreshAll()
end

function FoodFactoryProduct:GetUI(transform)
    self.txt_name = transform:Find("txt_name"):GetComponent(typeof(Text))
    self.txt_level = transform:Find("txt_level"):GetComponent(typeof(Text))
    self.icon = transform:Find("Item/Icon"):GetComponent(typeof(Image))
    self.txt_count = transform:Find("Item/txt_count"):GetComponent(typeof(Text))
    self.txt_process_time = transform:Find("txt_process_time"):GetComponent(typeof(Text))

    self.txt_title_cost = transform:Find("Cost/txt_title"):GetComponent(typeof(Text))
    self.itemParent = transform:Find("Cost/Layout")

    self.btn_product = transform:Find("btn_product"):GetComponent(typeof(Button))
    self.txt_name_product = transform:Find("btn_product/txt_name"):GetComponent(typeof(Text))

    self.btn_disable = transform:Find("btn_disable"):GetComponent(typeof(Button))
    self.txt_name_product_disable = transform:Find("btn_disable/txt_name"):GetComponent(typeof(Text))

    self.btn_productIng = transform:Find("btn_productIng"):GetComponent(typeof(Button))
    self.txt_name_productIng =  transform:Find("btn_productIng/txt_name"):GetComponent(typeof(Button))

    local function OnClick_btn_product(go)
        AppServices.NetBuildingManager:SendStartProduction(self.arguments.id)
        PanelManager.closePanel(GlobalPanelEnum.FoodFactoryPanel)
    end
    --insertDeclareBtn
	Util.UGUI_AddButtonListener(self.btn_product.gameObject, OnClick_btn_product)
	--insertDeclareBtn
end

function FoodFactoryProduct:refreshAll()
    local agent = App.scene.objectManager:GetAgent(self.arguments.id)
    local level = agent.data:GetLevel()

    local factoryUnit = agent:GetFactoryUnit()
    self.productionData = factoryUnit:GetProductionData()

    local status = AppServices.User:ProductionStatue(self.productionData)
    self.isProducting = status == ProductionStatus.Doing
    if status == ProductionStatus.Doing then
        self.productingLevel = self.productionData.level    -- 生产中的等级
    else
        self.productingLevel = level
    end

    local useLevel = self.isProducting and self.productingLevel or level

    local key = AppServices.BuildingLevelTemplateTool:GetKey(self.arguments.sn, useLevel)
    self.data = AppServices.Meta:Category("BuildingLevelTemplate")[tostring(key)]

    if self.data then
        self:refreshFactory()
        self:refreshProduct()
        self:refreshProductBtn()
        self:refreshCost()
        if self.isProducting then
            self.waitExtensionId = WaitExtension.InvokeRepeating(function() self:refreshProductTime() end, 0, 1)
        end
    end
end

function FoodFactoryProduct:refreshFactory()
    self.txt_name.text = self.data.name
    self.txt_level.text = string.format("Lv.%d", self.data.level)

    if self.isProducting then
        self:refreshProductTime()
    else
        self.txt_process_time.text = TimeUtil.SecToMS(self.data.time) -- FactoryTimeTool:TimeToStr(self.data.time)
    end
end

function FoodFactoryProduct:refreshProductTime()
    local time = self.productionData.endTime - TimeUtil.ServerTime()
    time = math.max(time, 0)
    self.txt_process_time.text = TimeUtil.SecToMS(time) -- FactoryTimeTool:TimeToStr(self.data.time)
    if time <= 0 then
        self:RemoveWaitExtension()
        PanelManager.closePanel(GlobalPanelEnum.FoodFactoryPanel)
    end
end

function FoodFactoryProduct:RemoveWaitExtension()
    if self.waitExtensionId then
        WaitExtension.CancelTimeout(self.waitExtensionId)
        self.waitExtensionId = nil
    end
end

function FoodFactoryProduct:refreshProduct()
    if #self.data.production <= 0 then
        return
    end
    local production = self.data.production[1]

    local itemKey = production[1]
    local count = production[2]

    local itemData = AppServices.Meta:Category("ItemTemplate")[tostring(itemKey)]
    self.icon.sprite = self:GetItemSprite(itemData.icon)
    self.txt_count.text = string.format("x%d", count)
end

function FoodFactoryProduct:refreshCost()
    for index = 1, #self.data.material do
        local name = string.format("Item%d", index)
        local itemTr = self.itemParent:Find(name)

        if Runtime.CSValid(itemTr) then
            local material = self.data.material[index]
            local itemKey = tostring(material[1])

            local icon = itemTr:Find("Icon"):GetComponent(typeof(Image))
            local txt_count = itemTr:Find("txt_count"):GetComponent(typeof(Text))

            local itemData = AppServices.Meta:Category("ItemTemplate")[itemKey]
            icon.sprite = self:GetItemSprite(itemData.icon)

            local ownerCount = AppServices.User:GetItemAmount(tonumber(itemKey))
            txt_count.text = string.format("%d/%d", material[2], ownerCount)
            itemTr.gameObject:SetActive(true)
        end
    end
end

function FoodFactoryProduct:refreshProductBtn()
    local enougth = AppServices.ItemCostManager:IsItemEnougth(self.data.material)

    local showProduct = (not self.isProducting) and enougth
    self.btn_product.gameObject:SetActive(showProduct)

    local showDisable = (not self.isProducting) and (not enougth)
    self.btn_disable.gameObject:SetActive(showDisable)

    local showIng = self.isProducting
    self.btn_productIng.gameObject:SetActive(showIng)
end

function FoodFactoryProduct:Hide()
    self:RemoveWaitExtension()
end

function FoodFactoryProduct:GetItemSprite(spriteName)
    local atlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_ITEM_ICONS)
    local sprite = atlas:GetSprite(spriteName)
    return sprite
end

return FoodFactoryProduct