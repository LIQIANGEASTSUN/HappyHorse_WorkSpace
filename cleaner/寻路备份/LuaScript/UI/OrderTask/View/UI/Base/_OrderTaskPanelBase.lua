--insertRequire

---@class _OrderTaskPanelBase:BasePanel
local _OrderTaskPanelBase = class(BasePanel)

function _OrderTaskPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.btn_close = nil
    self.onClick_btn_close = nil
    self.go_orderInfo = nil
    self.go_orderCd = nil
end

function _OrderTaskPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _OrderTaskPanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        local go = self.gameObject
        self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))
        -- 标题
        self.label_title = find_component(go, 'label_title', Text)

        -- 订单信息部分
        self.go_orderInfo = self.gameObject.transform:Find("go_orderInfo").gameObject
        self.btn_delete = find_component(go, "go_orderInfo/btn_delete", Button)
        self.btn_submit = find_component(go, "go_orderInfo/btn_submit", Button)
        -- self.slider_submit = find_component(go, "go_orderInfo/btn_submit/slider_submit", Slider)
        self.img_progress = find_component(go, "go_orderInfo/btn_submit/img_progress", Image)
        self.submit_effect = find_component(go,"go_orderInfo/btn_submit/effect")
        self.label_submit = find_component(go, "go_orderInfo/btn_submit/label_submit", Text)
        self.img_npc = find_component(go, "go_orderInfo/img_npc", RawImage)
        self.label_npcName = find_component(go, "go_orderInfo/label_npcName", Text)

        self.go_layout_ordeItems = find_component(go, "go_orderInfo/go_layout_ordeItems")
        self.go_orderItem = find_component(go, "go_orderInfo/go_layout_ordeItems/go_orderItem")
        -- CD部分
        self.go_orderCd = self.gameObject.transform:Find("go_orderCd").gameObject
        self.label_cdTips = find_component(go, "go_orderCd/label_cdTips", Text)
        self.label_newOrder = find_component(go, "go_orderCd/label_newOrder", Text)
        self.label_clear = find_component(go, "go_orderCd/btn_clearCD/label_clear", Text)
        self.label_clearCost = find_component(go, "go_orderCd/btn_clearCD/label_clearCost", Text)
        self.img_clearIcon = find_component(go, "go_orderCd/btn_clearCD/img_clearIcon", Image)
        self.label_orderCD = find_component(go, "go_orderCd/label_orderCD", Text)
        self.btn_clearCD = find_component(go, "go_orderCd/btn_clearCD", Button)
        --广告
        self.go_orderAds = self.gameObject.transform:Find("go_orderAds").gameObject
        self.btn_delete_ads = find_component(go, "go_orderAds/btn_delete", Button)
        self.btn_ads = find_component(go, "go_orderAds/btn_submit", Button)
        self.label_ads = find_component(go, "go_orderAds/btn_submit/label_submit", Text)
        self.label_lab1 = find_component(go, "go_orderAds/lab1", Text)
        self.label_lab2 = find_component(go, "go_orderAds/lab2", Text)
        -- 订单九宫格
        self.go_layout_orders = find_component(go, 'orders/go_layout_orders')

        ---上方进度条
        self.label_orderProgressCd = find_component(go, 'label_orderProgressCd', Text)
        self.go_orderPorgress = find_component(go, 'orderProgress')
        self.label_progress = find_component(go, 'orderProgress/label_progress', Text)
        self.slider_orderProgress = find_component(go, 'orderProgress/slider_orderProgress', Slider)
        self.go_awardNode = find_component(go, 'orderProgress/slider_orderProgress/go_awardNode')
        --insertInitComp
        Runtime.Localize(self.label_cdTips, 'ui_order_cd_text')
        Runtime.Localize(self.label_newOrder, 'ui_order_cd_new')
        Runtime.Localize(self.label_clear, 'ui_order_cd_skip')
        Runtime.Localize(self.label_title, 'ui_order_title')
        Runtime.Localize(self.label_submit, 'ui_order_deliver')
        Runtime.Localize(self.label_ads, "UI_Ads_button")
        Runtime.Localize(self.label_lab2, "UI_Ads_order_title")
        Runtime.Localize(self.label_lab1, "UI_Ads_order_text")

        --insertOnClick

        local function OnClick_btn_close(go)
            sendNotification(OrderTaskPanelNotificationEnum.Click_btn_close)
        end
        --insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
        Util.UGUI_AddButtonListener(self.btn_submit, function()
            if self:IsClickBlock() then
                return
            end
            sendNotification(OrderTaskPanelNotificationEnum.Submit_Order, {position = self.SelectPosition})
        end)
        Util.UGUI_AddButtonListener(self.btn_delete, function()
            sendNotification(OrderTaskPanelNotificationEnum.Delete_Order, {position = self.SelectPosition})
        end)

        Util.UGUI_AddButtonListener(self.btn_clearCD, function()
            sendNotification(OrderTaskPanelNotificationEnum.ClearCD, {position = self.SelectPosition})
        end)

        Util.UGUI_AddButtonListener(self.btn_delete_ads, function()
            sendNotification(OrderTaskPanelNotificationEnum.Delete_Order, {position = self.SelectPosition})
        end)

        Util.UGUI_AddButtonListener(self.btn_ads, function()
            sendNotification(OrderTaskPanelNotificationEnum.Click_Ads, {position = self.SelectPosition})
        end)
    end
end

--insertSetTxt

return _OrderTaskPanelBase
