--insertRequire
---@class _MailCollectPanelBase:BasePanel
local _MailCollectPanelBase = class(BasePanel)

function _MailCollectPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
	self.text_title = nil
	self.btn_collect = nil
	self.onClick_btn_collect = nil
end

function _MailCollectPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _MailCollectPanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
		self.text_title = self.gameObject.transform:Find("text_title").gameObject:GetComponent(typeof(Text))
		self.btn_collect = self.gameObject.transform:Find("btn_collect").gameObject:GetComponent(typeof(Button))
		self.txt_btn_collect = find_component(self.btn_collect,'Text',Text)
		self.txt_description = find_component(self.gameObject,'txt_description',Text)

		self.tran_list_parent = find_component(self.gameObject,'Scroll View/Viewport/Content',Transform)
		self.tran_list_item = find_component(self.gameObject,'Scroll View/item',Transform)

		self.oneRowContent = find_component(self.gameObject, "Content", Transform)
		self.oneRowItem = find_component(self.gameObject, "item")
	--insertInitComp
	--insertOnClick

		local function OnClick_btn_collect(go)
			sendNotification(MailCollectPanelNotificationEnum.Click_btn_collect)
		end
	--insertDeclareBtn
		Util.UGUI_AddButtonListener(self.btn_collect.gameObject, OnClick_btn_collect)
	end

end

--insertSetTxt

return _MailCollectPanelBase
