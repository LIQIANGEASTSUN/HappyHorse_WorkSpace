--insertRequire

---@class _PetUpStagePanelBase:BasePanel
local _PetUpStagePanelBase = class(BasePanel)

function _PetUpStagePanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
	self.btn_close = nil

end

function _PetUpStagePanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _PetUpStagePanelBase:bindView()

	if(self.gameObject ~= nil) then
		--insertInit

		local transform = self.gameObject.transform
		self.btn_close = transform:Find("BG/btn_close"):GetComponent(typeof(Button))

		self.txt_title = transform:Find("BG/txt_title"):GetComponent(typeof(Text))
		self.txt_level_info = transform:Find("BG/txt_level_info"):GetComponent(typeof(Text))
		self.icon = transform:Find("BG/IconBG/Icon"):GetComponent(typeof(Image))
		self.txt_cost_title = transform:Find("BG/txt_cost"):GetComponent(typeof(Text))
		self.itemParent = transform:Find("BG/Layout")
		self.btn_up_stage = transform:Find("BG/btn_up_stage"):GetComponent(typeof(Button))
		self.btn_disable = transform:Find("BG/btn_disable"):GetComponent(typeof(Button))
		self.txt_disable = transform:Find("BG/btn_disable/txt_name"):GetComponent(typeof(Text))

		--insertInitComp
		--insertOnClick
		local function OnClick_btn_close(go)
			sendNotification(PetUpStagePanelNotificationEnum.Click_btn_close)
		end

		local function OnClick_btn_up_stage()
			sendNotification(PetUpStagePanelNotificationEnum.Click_btn_up_stage)
		end

		local function OnClick_btn_disable()
			sendNotification(PetUpStagePanelNotificationEnum.Click_btn_up_disable)
		end
		--insertDeclareBtn
		Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
		Util.UGUI_AddButtonListener(self.btn_up_stage.gameObject, OnClick_btn_up_stage)
		Util.UGUI_AddButtonListener(self.btn_disable.gameObject, OnClick_btn_disable)
		--insertDeclareBtn
	end

end

--insertSetTxt

return _PetUpStagePanelBase
