--insertRequire

---@class _PetIllustratedPanelBase:BasePanel
local _PetIllustratedPanelBase = class(BasePanel)

function _PetIllustratedPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
    self.btn_close = nil
	self.battleTeam = nil
	self.editorTeam = nil
	self.illustratedGroup = nil
end

function _PetIllustratedPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _PetIllustratedPanelBase:bindView()
	if (self.gameObject ~= nil) then
	--insertInit
        self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))

		self.illustrated = self.gameObject.transform:Find("Illustrated")
		self.battleTeamEditor = self.gameObject.transform:Find("BattleTeamEditor")
	--insertInitComp

	--insertOnClick
        local function OnClick_btn_close(go)
            sendNotification(PetIllustratedPanelNotificationEnum.Click_btn_close)
        end
	--insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
	end

end

--insertSetTxt

return _PetIllustratedPanelBase
