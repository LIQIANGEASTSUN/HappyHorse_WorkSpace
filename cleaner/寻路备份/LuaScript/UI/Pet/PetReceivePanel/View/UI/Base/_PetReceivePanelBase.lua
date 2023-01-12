--insertRequire

---@class _PetReceivePanelBase:BasePanel
local _PetReceivePanelBase = class(BasePanel)

function _PetReceivePanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
    self.btn_close = nil
    self.onClick_btn_close = nil
	self.txt_title = nil
end

function _PetReceivePanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _PetReceivePanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
        self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))
        self.txt_title = find_component(self.gameObject, 'Panel/Title/txt_title', Text)
		local petInfoGo =  find_component(self.gameObject, 'Panel/PetInfo', Transform)
		self.icon = find_component(petInfoGo, 'Icon', Image)
		self.txt_hp = find_component(petInfoGo, 'hpIcon/txt_hp', Text)
		self.txt_attack = find_component(petInfoGo, 'attackIcon/txt_hp', Text)
		self.btn_backpack = find_component(petInfoGo, 'Group/btn_backpack', Button)
		self.btn_team = find_component(petInfoGo, 'Group/btn_team', Button)
	--insertInitComp
	--insertOnClick
        local function OnClick_btn_close(go)
            sendNotification(PetReceivePanelNotificationEnum.Click_btn_close)
        end

		local function OnClick_backback(go)
            sendNotification(PetReceivePanelNotificationEnum.Click_btn_close)
		end

		local function OnClick_team(go)
            sendNotification(PetReceivePanelNotificationEnum.Click_btn_close)
		end
	--insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
		Util.UGUI_AddButtonListener(self.btn_backpack.gameObject, OnClick_backback)
		Util.UGUI_AddButtonListener(self.btn_team.gameObject, OnClick_team)
	end

end

--insertSetTxt

return _PetReceivePanelBase
