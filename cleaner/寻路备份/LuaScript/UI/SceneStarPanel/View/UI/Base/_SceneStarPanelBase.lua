--insertRequire

---@class _SceneStarPanelBase:BasePanel
local _SceneStarPanelBase = class(BasePanel)

function _SceneStarPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
    self.btn_rewardMask = nil
    self.onClick_btn_rewardMask = nil
    self.text_get2 = nil
    self.text_tip1 = nil
    self.text_tip2 = nil
    self.text_tip3 = nil
    self.text_tip4 = nil
    self.text_tip5 = nil
    self.c2_title = nil
    self.text_title = nil
    self.c2_rightTop = nil
    self.btn_rewardTip = nil
    self.onClick_btn_rewardTip = nil
    self.img_starProcess = nil
    self.c2_time = nil
    self.text_time = nil
    self.c2_outTime = nil
    self.text_outTime = nil
    self.text_starCount = nil
    self.c2_rewardRoot = nil
    self.text_tip6 = nil
    self.text_tip7 = nil
    self.btn_get1 = nil
    self.onClick_btn_get1 = nil
    self.btn_get2 = nil
    self.onClick_btn_get2 = nil
    self.btn_close = nil
    self.onClick_btn_close = nil
    self.go_get1 = nil
    self.go_get2 = nil
    self.text_get1 = nil
    self.go_flyRewardPos = nil
    self.c2_get = nil
    self.text_get = nil
end

function _SceneStarPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _SceneStarPanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
        self.btn_rewardMask = self.gameObject.transform:Find("btn_rewardMask").gameObject:GetComponent(typeof(Button))
        self.text_get2 = self.gameObject.transform:Find("text_get2").gameObject:GetComponent(typeof(Text))
        self.text_tip1 = self.gameObject.transform:Find("text_tip1").gameObject:GetComponent(typeof(Text))
        self.text_tip2 = self.gameObject.transform:Find("text_tip2").gameObject:GetComponent(typeof(Text))
        self.text_tip3 = self.gameObject.transform:Find("text_tip3").gameObject:GetComponent(typeof(Text))
        self.text_tip4 = self.gameObject.transform:Find("text_tip4").gameObject:GetComponent(typeof(Text))
        self.text_tip5 = self.gameObject.transform:Find("text_tip5").gameObject:GetComponent(typeof(Text))
        self.c2_title = self.gameObject.transform:Find("c2_title").gameObject
        self.c2_stars = self.gameObject.transform:Find("c2_stars").gameObject
        self.text_title = self.c2_title.transform:Find("text_title").gameObject:GetComponent(typeof(Text))
        self.c2_rightTop = self.gameObject.transform:Find("c2_rightTop").gameObject
        self.btn_rewardTip = self.c2_rightTop.transform:Find("btn_rewardTip").gameObject:GetComponent(typeof(Button))
        self.img_starProcess = self.c2_rightTop.transform:Find("img_starProcess").gameObject:GetComponent(typeof(Image))
        self.c2_time = self.c2_rightTop.transform:Find("c2_time").gameObject
        self.text_time = self.c2_time.transform:Find("text_time").gameObject:GetComponent(typeof(Text))
        self.c2_outTime = self.c2_rightTop.transform:Find("c2_outTime").gameObject
        self.text_outTime = self.c2_outTime.transform:Find("text_outTime").gameObject:GetComponent(typeof(Text))
        self.text_starCount = self.c2_rightTop.transform:Find("text_starCount").gameObject:GetComponent(typeof(Text))
        self.c2_rewardRoot = self.c2_rightTop.transform:Find("c2_rewardRoot").gameObject
        self.text_tip6 = self.c2_rewardRoot.transform:Find("text_tip6").gameObject:GetComponent(typeof(Text))
        self.text_tip7 = self.c2_rightTop.transform:Find("text_tip7").gameObject:GetComponent(typeof(Text))
        self.btn_get1 = self.gameObject.transform:Find("btn_get1").gameObject:GetComponent(typeof(Button))
        self.btn_get2 = self.gameObject.transform:Find("btn_get2").gameObject:GetComponent(typeof(Button))
        self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))
        self.go_get1 = self.gameObject.transform:Find("go_get1").gameObject
        self.go_get2 = self.gameObject.transform:Find("go_get2").gameObject
        self.text_get1 = self.gameObject.transform:Find("text_get1").gameObject:GetComponent(typeof(Text))
        self.go_flyRewardPos = self.gameObject.transform:Find("go_flyRewardPos").gameObject
        self.c2_get = self.c2_rightTop.transform:Find("c2_get").gameObject
        self.text_get = self.c2_get.transform:Find("text_get").gameObject:GetComponent(typeof(Text))

        self.guideFlag1 = find_component(self.gameObject, "guideFlag1", Transform)
        self.guideFlag2 = find_component(self.gameObject, "guideFlag2", Transform)

        ---完成提示
        local go = self.gameObject
        self.stars = find_component(go, "c2_stars")
        self.go_alldone = find_component(go, "go_alldone")
        self.mapInfo_limitreward = find_component(self.go_alldone, "mapInfo_limitreward")
        self.mapInfo_normal = find_component(self.go_alldone, "mapInfo_normal")
        self.map_desc1 = find_component(self.mapInfo_limitreward, "txt_desc", Text)
        self.map_desc2 = find_component(self.mapInfo_normal, "txt_desc", Text)
        self.map_icon1 = find_component(self.mapInfo_limitreward, "icon", Image)
        self.map_icon2 = find_component(self.mapInfo_normal, "icon", Image)
        Runtime.Localize(self.map_desc1, "UI_star_finish")
        Runtime.Localize(self.map_desc2, "UI_star_finish")
        self.limitreward_itemDesc = find_component(self.go_alldone, "items/txt_itemdesc", Text)
        self.items = find_component(self.go_alldone, "items")
        self.layout_items = find_component(self.items, "layout_items")
        self.limitreward_itemNode = find_component(self.layout_items, "itemNode")
        local itemsreward_txt = find_component(self.items, "txt_itemdesc", Text)
        Runtime.Localize(itemsreward_txt, "UI_star_finish_reward")
        self.btn_ok = find_component(self.go_alldone, "Button/btn_ok", Button)
        self.btn_ok_txt = find_component(self.go_alldone, "Button/btn_ok/Text", Text)
        self.go_alldone:SetActive(false)
        self.stars:SetActive(true)
        local function on_click_btn_ok(go)
            sendNotification(SceneStarPanelNotificationEnum.Click_btn_ok)
        end
        Util.UGUI_AddButtonListener(self.btn_ok.gameObject, on_click_btn_ok)
        Runtime.Localize(self.btn_ok_txt, "UI_button_new_scene")
	--insertInitComp
	--insertOnClick
        local function OnClick_btn_rewardMask(go)
            sendNotification(SceneStarPanelNotificationEnum.Click_btn_rewardMask)
        end
        local function OnClick_btn_rewardTip(go)
            sendNotification(SceneStarPanelNotificationEnum.Click_SceneStarPanel_btn_rewardTip)
        end
        local function OnClick_btn_get1(go)
            sendNotification(SceneStarPanelNotificationEnum.Click_btn_get1)
        end
        local function OnClick_btn_get2(go)
            sendNotification(SceneStarPanelNotificationEnum.Click_btn_get2)
        end
        local function OnClick_btn_close(go)
            sendNotification(SceneStarPanelNotificationEnum.Click_btn_close)
        end
	--insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_rewardMask.gameObject, OnClick_btn_rewardMask)
        Util.UGUI_AddButtonListener(self.btn_rewardTip.gameObject, OnClick_btn_rewardTip)
        Util.UGUI_AddButtonListener(self.btn_get1.gameObject, OnClick_btn_get1)
        Util.UGUI_AddButtonListener(self.btn_get2.gameObject, OnClick_btn_get2)
        Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
	end

end

--insertSetTxt

return _SceneStarPanelBase
