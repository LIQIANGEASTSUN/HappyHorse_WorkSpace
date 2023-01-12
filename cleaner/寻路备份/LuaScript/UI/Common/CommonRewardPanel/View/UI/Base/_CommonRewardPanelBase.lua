--insertRequire
---@class _CommonRewardPanelBase : BasePanel
local _CommonRewardPanelBase = class(BasePanel)

function _CommonRewardPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
	self.text_continue = nil
	self.btn_hitLayer = nil
	self.onClick_btn_hitLayer = nil
end

function _CommonRewardPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _CommonRewardPanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
		self.text_continue = find_component(self.gameObject, "text_continue", Text)
		self.txt_desc1 = find_component(self.gameObject, "txt_desc1", Text)
		self.txt_desc2 = find_component(self.gameObject, "txt_desc2", Text)
		self.btn_hitLayer = self.gameObject.transform:Find("btn_hitLayer").gameObject:GetComponent(typeof(Button))
		self.btn_nextLayer = self.gameObject.transform:Find("btn_nextLayer").gameObject:GetComponent(typeof(Button))
		self.container_items = self.gameObject:FindComponentInChildren("ItemContaniner",typeof(RewardContainer))
		self.container_buildings = self.gameObject:FindComponentInChildren("BuildingContainer",typeof(RewardContainer))
		self.go_halo_panel = self.gameObject:FindGameObject("HaloPanel")
		self.txt_congrats = find_component(self.gameObject, "txt_congrats", Text)
		self.newkind = find_component(self.gameObject, "newkind")
		self.txt_newKind = find_component(self.newkind, "txt_newKind", Text)
		self.txt_dragonNum = find_component(self.gameObject, "txt_dragonNum", Text)
		self.gridRoot = find_component(self.gameObject, "gridRoot", Transform)
		self.gridRoot_2 = find_component(self.gameObject, "gridRoot_2", Transform)
		self.specialMask = find_component(self.gameObject, "gridRoot_2/specialMask", Image)

		self.txt_name = find_component(self.gameObject, "txt_name", Text)
		self.icon_dragon_attri = find_component(self.txt_name, "icon_attri", Image)
		self.txt_dragon_product = find_component(self.gameObject, "txt_dragon_product", Text)
		self.icon_dragon_product = find_component(self.txt_dragon_product, "icon", Image)
		self.productLimit = find_component(self.gameObject, "productLimit", Text)

		self.mark = find_component(self.gameObject, "mark")
		self.newFlag = find_component(self.mark, "newFlag")
		self.m_txtRare = find_component(self.mark, string.format("rare/text_rare"), Text)
		--insertInitComp
		--insertOnClick
		Runtime.Localize(self.text_continue, "ui_common_receive")

		self.onClick_btn_hitLayer = function()
			sendNotification(CommonRewardPanelNotificationEnum.Click_btn_hitLayer)
		end

		local function OnClick_btn_hitLayer(go)
			if(self.onClick_btn_hitLayer ~=  nil) then
				self.onClick_btn_hitLayer()
			end
		end
	--insertDeclareBtn
		Util.UGUI_AddButtonListener(self.btn_hitLayer.gameObject, OnClick_btn_hitLayer)

		local function OnClick_btn_nextLayer(go)
			sendNotification(CommonRewardPanelNotificationEnum.Click_btn_nextLayer)
		end
		--insertDeclareBtn
		Util.UGUI_AddButtonListener(self.btn_nextLayer.gameObject, OnClick_btn_nextLayer)
	end

end

--insertSetTxt

return _CommonRewardPanelBase
