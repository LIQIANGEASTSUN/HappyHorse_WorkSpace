--insertRequire

---@class _PetInfoPanelBase:BasePanel
local _PetInfoPanelBase = class(BasePanel)

function _PetInfoPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
    self.btn_close = nil
    self.onClick_btn_close = nil

	self.typeUI = {}
	self.itemParent = nil
	self.item = nil
end

function _PetInfoPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _PetInfoPanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
        self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))
		self:GetType()

		self.itemParent = find_component(self.gameObject, 'Panel/ScrollView/Viewport/Content', Transform)
		self.item = find_component(self.itemParent.gameObject, 'Item', Transform)
	--insertInitComp
	--insertOnClick
        local function OnClick_btn_close(go)
            sendNotification(PetInfoPanelNotificationEnum.Click_btn_close)
        end
	--insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
	end

end

function _PetInfoPanelBase:GetType()
	local typeGo = find_component(self.gameObject,'Panel/Type',Transform).gameObject
    for i = 1, 2 do
		local item = {}

        local name = string.format("Type%d", i)
		local typeItem = typeGo.transform:Find(name).gameObject:GetComponent(typeof(Transform))
		item.btn = typeItem.gameObject:GetComponent(typeof(Button))
		item.select = find_component(typeItem.gameObject, 'Select', Transform)
		item.txt_select = find_component(typeItem.gameObject, 'Select/txt_name', Transform)
		item.unSelect = find_component(typeItem.gameObject, 'UnSelect', Transform)
		item.txt_unSelect = find_component(typeItem.gameObject, 'UnSelect/txt_name', Transform)

		local body = { index = i }
		Util.UGUI_AddButtonListener(item.btn.gameObject, function(go)
			sendNotification(PetInfoPanelNotificationEnum.Type_btn_click, body)
		end)
		table.insert(self.typeUI, item)
	end
end

--insertSetTxt

return _PetInfoPanelBase
