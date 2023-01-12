--insertRequire

---@class _GuideItemTipPanelBase:BasePanel
local _GuideItemTipPanelBase = class(BasePanel)

function _GuideItemTipPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
end

function _GuideItemTipPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _GuideItemTipPanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
	self.txtTittle = find_component(self.gameObject, "bg/txtTittle", Text)
	self.imgIcon = find_component(self.gameObject, "bg/imgIcon", Image)
	self.txtContent = find_component(self.gameObject, "bg/txtContent", Text)
	self.btnGo = find_component(self.gameObject, "bg/btnGo")
	self.txtGo = find_component(self.gameObject, "bg/btnGo/txtGo", Text)
	--insertInitComp
	--insertOnClick
	--insertDeclareBtn
	end

end

--insertSetTxt

return _GuideItemTipPanelBase
