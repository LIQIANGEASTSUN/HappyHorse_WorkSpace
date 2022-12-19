--insertRequire

---@class _SingleRewardPanelBase:BasePanel
local _SingleRewardPanelBase = class(BasePanel)

function _SingleRewardPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.btn_ok = nil
    self.onClick_btn_ok = nil
end

function _SingleRewardPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _SingleRewardPanelBase:bindView()
    if (self.gameObject ~= nil) then
        local go = self.gameObject
        self.btn_ok = find_component(go, "btn_ok")
		local label_ok = find_component(self.btn_ok, "label_ok", Text)
		Runtime.Localize(label_ok, "ui_common_ok")
		local label_title = find_component(go, "label_title", Text)
		Runtime.Localize(label_title, "ui_obstacleui_congrats")
		local label_tip = find_component(go, "label_tip", Text)
		Runtime.Localize(label_tip, "ui_obstacleui_receive")
        local go_rewardItem = find_component(go, 'go_rewardItem')
		self.icon = find_component(go_rewardItem, "icon", Image)
		self.raw_icon = find_component(go_rewardItem, "raw_icon", RawImage)
		self.num = find_component(go_rewardItem, "num", Text)

		self.label_itemName = find_component(go, "label_itemName", Text)
		self.label_itemDesc = find_component(go, "label_itemDesc", Text)
        --insertInitComp
        --insertOnClick
        local function OnClick_btn_ok(go)
            sendNotification(SingleRewardPanelNotificationEnum.Click_btn_ok)
        end
        --insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_ok.gameObject, OnClick_btn_ok)
    end
end

--insertSetTxt

return _SingleRewardPanelBase
