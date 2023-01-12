--insertRequire

---@class _AdsSimpleRewardPanelBase:BasePanel
local _AdsSimpleRewardPanelBase = class(BasePanel)

function _AdsSimpleRewardPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
    -- self.go_ItemContaniner = nil
end

function _AdsSimpleRewardPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _AdsSimpleRewardPanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
        -- self.go_ItemContaniner = self.gameObject.transform:Find("go_ItemContaniner").gameObject
		self.container_items = find_component(self.gameObject, 'go_ItemContaniner', RewardContainer)
		self.getBtn = find_component(self.gameObject, "btnRoot/getBtn")
		self.adsBtn = find_component(self.gameObject, "btnRoot/adsBtn")
		self.effectRoot = find_component(self.gameObject, "effectRoot")
		self.text_tip = find_component(self.gameObject, "text_tip", Text)
		self.text_title = find_component(self.gameObject, "text_title", Text)

	--insertInitComp
	--insertOnClick
	--insertDeclareBtn
	end

end

--insertSetTxt

return _AdsSimpleRewardPanelBase
