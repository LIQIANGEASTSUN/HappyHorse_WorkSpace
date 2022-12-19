--insertRequire

---@class _DecorationFactoryPanelBase:BasePanel
local _DecorationFactoryPanelBase = class(BasePanel)

function _DecorationFactoryPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.btn_close = nil
    self.onClick_btn_close = nil
    self.go_levelup = nil
    self.go_product = nil
end

function _DecorationFactoryPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _DecorationFactoryPanelBase:bindView()
    if (self.gameObject ~= nil) then
        local go = self.gameObject
        --insertInit
        self.btn_close = find_component(go, "btn_close", Button)
        local go_levelmax = find_component(go, "go_levelmax")
        local txt_lvupTitle = find_component(go_levelmax, "txt_lvupTitle", Text)
        local txt_levelMaxDesc = find_component(go_levelmax, "txt_levelMaxDesc", Text)
        txt_lvupTitle.text = "升级"
        txt_levelMaxDesc.text = "已满级"
        self.go_levelmax = go_levelmax
        self.txt_levelMax = find_component(go_levelmax, "txt_levelMax", Text)

        local go_levelup = find_component(go, "go_levelup")
        self.go_levelup = go_levelup
        self.btn_levelUp = find_component(go_levelup, "btn_levelUp", Button)
        local txt_levelUp = find_component(self.btn_levelUp, "Text", Text)
        -- Runtime.Localize(txt_levelUp, "ui_decorationFactory_btn_levelUp") --升级
        txt_levelUp.text = "升级"
        self.txt_level = find_component(go_levelup, "txt_level", Text)
        self.txt_level_next = find_component(go_levelup, "txt_level_next", Text)

        self.txt_lvupTitle = find_component(go_levelup, "txt_lvupTitle", Text)
        Runtime.Localize(self.txt_lvupTitle, "ui_decorationFactory_lvupTitle") --升级
        self.txt_lvupTitle.text = "升级"
        self.txt_improveTitle = find_component(go_levelup, "txt_improveTitle", Text)
        Runtime.Localize(self.txt_improveTitle, "ui_decorationFactory_improveTitle") --升级提升
        self.txt_improveTitle.text = "升级提升"
        self.txt_unlockDesc = find_component(go_levelup, "txt_unlockDesc", Text)
        Runtime.Localize(self.txt_lvupTitle, "ui_decorationFactory_unlockDesc") --解锁建筑
        self.txt_lvupTitle.text = "解锁建筑"
        self.txt_costTitle = find_component(go_levelup, "txt_costTitle", Text)
        Runtime.Localize(self.txt_lvupTitle, "ui_decorationFactory_costTitle") --升级所需
        self.txt_lvupTitle.text = "升级所需"
        self.go_unlocks = find_component(go_levelup, "go_unlocks")
        self.go_unlockNode = find_component(self.go_unlocks, "go_unlockNode")
        self.go_lvupNeeds = find_component(go_levelup, "go_lvupNeeds")
        self.go_lvupNeedNode = find_component(self.go_lvupNeeds, "go_lvupNeedNode")

        ---产出
        local go_product = find_component(go, "go_product")
        self.go_product = go_product
        self.btn_canProduct = find_component(go_product, "btn_canProduct", Button)
        local txt_canProduct = find_component(self.btn_canProduct, "Text", Text)
        Runtime.Localize(txt_canProduct, "ui_decorationFactory_canProduct") --可生产建筑
        txt_canProduct.text = "可生产建筑"
        self.txt_curLevel = find_component(go_product, "txt_curLevel", Text)
        self.txt_name = find_component(go_product, "txt_name", Text)
        local txt_costTitle = find_component(go_product, "txt_costTitle", Text)
        Runtime.Localize(txt_costTitle, "ui_decorationFactory_cost_material") --所需材料
        txt_costTitle.text = "所需材料"
        self.go_productCost = find_component(go_product, "go_productCost")
        self.go_productCostNode = find_component(self.go_productCost, "go_productCostNode")
        self.btn_product = find_component(go_product, "btn_product", Button)
        local txt_product = find_component(self.btn_product, "Text", Text)
        Runtime.Localize(txt_product, "ui_decorationFactory_btn_product") --生产
        txt_product.text = "生产"
        --insertInitComp
        --insertOnClick
        local function OnClick_btn_close(go)
            sendNotification(DecorationFactoryPanelNotificationEnum.Click_btn_close)
        end

        local function OnClick_btn_product(go)
            sendNotification(DecorationFactoryPanelNotificationEnum.Click_btn_product)
        end

        local function OnClick_btn_levelUp(go)
            sendNotification(DecorationFactoryPanelNotificationEnum.Click_btn_levelUp)
        end
        local function OnClick_btn_canProduct(go)
            sendNotification(DecorationFactoryPanelNotificationEnum.Click_btn_canProduct)
        end
        --insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
        Util.UGUI_AddButtonListener(self.btn_product.gameObject, OnClick_btn_product)
        Util.UGUI_AddButtonListener(self.btn_levelUp.gameObject, OnClick_btn_levelUp)
        Util.UGUI_AddButtonListener(self.btn_canProduct.gameObject, OnClick_btn_canProduct)

        local keys = {
            "生产",
            "升级",
        }
        self.toggles = {}
        self.toggle = find_component(go, "toggle")
        for i = 1, 2 do
            local toggle = find_component(self.toggle, "toggleNode" .. i, Toggle)
            local label1 = find_component(toggle, "selected", Text)
            local label2 = find_component(toggle, "notSelect", Text)
            toggle.isOn = false
            toggle.onValueChanged:AddListener(
                function(isOn)
                    label1:SetActive(isOn)
                    label2:SetActive(not isOn)
                    if isOn then
                        self:OnClickTap(i)
                    end
                end
            )
            local state = i == 1
            label1:SetActive(state)
            label2:SetActive(not state)
            label1.text = keys[i]
            label2.text = keys[i]
            -- Runtime.Localize(label1, keys[i])
            -- Runtime.Localize(label2, keys[i])
            self.toggles[i] = toggle
        end
    end
end

--insertSetTxt

return _DecorationFactoryPanelBase
