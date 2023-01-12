--insertRequire

---@class _FoodFactoryPanelBase:BasePanel
local _FoodFactoryPanelBase = class(BasePanel)

function _FoodFactoryPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil

	--insertCtor
	self.btn_close = nil
	self.typeUI = {}

end

function _FoodFactoryPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _FoodFactoryPanelBase:bindView()

	if(self.gameObject ~= nil) then
		--insertInit
		self.btn_close = self.gameObject.transform:Find("Panel/btn_close").gameObject:GetComponent(typeof(Button))
		self:GetType()

		self.productTr = self.gameObject.transform:Find("Panel/Product")
		self.upLevelTr = self.gameObject.transform:Find("Panel/UpLevel")

		--insertInitComp
		--insertOnClick
		local function OnClick_btn_close(go)
			sendNotification(FoodFactoryPanelNotificationEnum.Click_btn_close)
		end
		--insertDeclareBtn
		Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
		--insertDeclareBtn
	end

end

function _FoodFactoryPanelBase:GetType()
	local typeGo = find_component(self.gameObject,'Panel/BG/Type',Transform).gameObject
    for i = 1, 2 do
		local item = {}

        local name = string.format("Type%d", i)
		local typeItem = typeGo.transform:Find(name).gameObject:GetComponent(typeof(Transform))
		item.btn = typeItem.gameObject:GetComponent(typeof(Button))
		item.select = find_component(typeItem.gameObject, 'Select', Transform)
		item.unSelect = find_component(typeItem.gameObject, 'Unselect', Transform)
		item.txt_name = find_component(typeItem.gameObject, 'txt_name', Transform)

		local body = { index = i }
		Util.UGUI_AddButtonListener(item.btn.gameObject, function(go)
			sendNotification(FoodFactoryPanelNotificationEnum.Type_btn_click, body)
		end)
		table.insert(self.typeUI, item)
	end
end

--insertSetTxt

return _FoodFactoryPanelBase
