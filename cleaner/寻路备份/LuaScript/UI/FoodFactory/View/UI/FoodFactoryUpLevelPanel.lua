---@class FoodFactoryUpLevelPanel
local FoodFactoryUpLevelPanel = {}

function FoodFactoryUpLevelPanel:refresh(transform, arguments)
    self.arguments = arguments

    self:GetUI(transform)

    local agent = App.scene.objectManager:GetAgent(self.arguments.id)
    local level = agent.data:GetLevel()

    local key = AppServices.BuildingLevelTemplateTool:GetKey(self.arguments.sn, level)
    self.data = AppServices.Meta:Category("BuildingLevelTemplate")[tostring(key)]

    if self.data.upgradeCost and #self.data.upgradeCost > 0 then
        local nextKey = AppServices.BuildingLevelTemplateTool:GetKey(self.arguments.sn, level + 1)
        self.nextData = AppServices.Meta:Category("BuildingLevelTemplate")[tostring(nextKey)]
    end

    self:refreshLevelInfo()
    self:refreshCost()
    self:refreshUpBtn()
end

function FoodFactoryUpLevelPanel:GetUI(transform)
    self.txt_title = transform:Find("Level/txt_title"):GetComponent(typeof(Text))
    self.curLevel = {}
    self.nextLevel = {}
    self.curLevel.txt_level =  transform:Find("Level/txt_level"):GetComponent(typeof(Text))
    self.nextLevel.txt_level =  transform:Find("Level/txt_level_next"):GetComponent(typeof(Text))

    self.txt_title2 = transform:Find("InfoChange/txt_title"):GetComponent(typeof(Text))
    self.curLevel.txt_time = transform:Find("InfoChange/txt_time1"):GetComponent(typeof(Text))
    self.nextLevel.txt_time = transform:Find("InfoChange/txt_time2"):GetComponent(typeof(Text))
    self.curLevel.txt_count = transform:Find("InfoChange/txt_count1"):GetComponent(typeof(Text))
    self.nextLevel.txt_count = transform:Find("InfoChange/txt_count2"):GetComponent(typeof(Text))

    self.txt_title_cost = transform:Find("Cost/txt_title"):GetComponent(typeof(Text))
    self.itemParent =  transform:Find("Cost/Layout"):GetComponent(typeof(Transform))

    self.btn_up_level = transform:Find("btn_up_level"):GetComponent(typeof(Button))
    self.txt_up_level = transform:Find("btn_up_level/txt_name"):GetComponent(typeof(Text))
    self.btn_disable = transform:Find("btn_disable"):GetComponent(typeof(Button))
    self.txt_name_disable = transform:Find("btn_disable/txt_name"):GetComponent(typeof(Text))

    local function OnClick_btn_uplevel(go)
        AppServices.NetBuildingManager:SendBuildLevel(self.arguments.id)
        PanelManager.closePanel(GlobalPanelEnum.FoodFactoryPanel)
    end
    --insertDeclareBtn
	Util.UGUI_AddButtonListener(self.btn_up_level.gameObject, OnClick_btn_uplevel)
end

function FoodFactoryUpLevelPanel:refreshLevelInfo()
    self.txt_title.text = "升级"
    self.txt_title2 = "升级"

    self.curLevel.txt_level.text = string.format("Lv.%d", self.data.level)
    self.curLevel.txt_time.text = string.format("生产时间:%s", TimeUtil.SecToMS(self.data.time))
    self.curLevel.txt_count.text = string.format("生产个数:%d 个", self.data.production[1][2])

    self:SetLevelInfo(self.nextLevel, self.nextData)
end

function FoodFactoryUpLevelPanel:SetLevelInfo(levelUI, data)
    if not data then
        levelUI.txt_level.text = ""
        levelUI.txt_time.text = ""
        levelUI.txt_count.text = ""
    else
        levelUI.txt_level.text = string.format("Lv.%d", data.level)
        levelUI.txt_time.text = TimeUtil.SecToMS(data.time) -- FactoryTimeTool:TimeToStr(data.time)
        levelUI.txt_count.text = string.format("%d 个", data.production[1][2])
    end
end

function FoodFactoryUpLevelPanel:refreshCost()
    for i = 1, #self.data.upgradeCost do
        local name = string.format("Item%d", i)
        local itemTr = self.itemParent:Find(name)

        if Runtime.CSValid(itemTr) then
            local material = self.data.upgradeCost[i]
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

function FoodFactoryUpLevelPanel:refreshUpBtn()
    local result = AppServices.BuildingLevelTemplateTool:EnableUp(self.data)

    self.btn_up_level.gameObject:SetActive(result == UpgradeEnableType.Enable)
    self.btn_disable.gameObject:SetActive(result ~= UpgradeEnableType.Enable)
    if result == UpgradeEnableType.Enable then
        self.txt_up_level.text = "升级"
    else
        local disable = ""
        if result == UpgradeEnableType.ItemNotEnougth then
            disable = "材料不足"
        elseif result == UpgradeEnableType.PlayerLevelSmall then
            disable = string.format("需要达到Lv.%d", self.data.roleLevel)
        elseif result == UpgradeEnableType.MaxLevel then
            disable = "最大等级"
        end
        self.txt_name_disable.text = disable
    end
end

function FoodFactoryUpLevelPanel:GetItemSprite(spriteName)
    local atlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_ITEM_ICONS)
    local sprite = atlas:GetSprite(spriteName)
    return sprite
end

function FoodFactoryUpLevelPanel:Hide()

end

return FoodFactoryUpLevelPanel