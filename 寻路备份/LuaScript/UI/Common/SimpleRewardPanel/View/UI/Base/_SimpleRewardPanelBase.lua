--insertRequire

---@class _SimpleRewardPanelBase:BasePanel
local _SimpleRewardPanelBase = class(BasePanel)

function _SimpleRewardPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.container_items = nil
end

function _SimpleRewardPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _SimpleRewardPanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        -- self.go_ItemContaniner = self.gameObject.transform:Find("go_ItemContaniner").gameObject
        self.container_items = find_component(self.gameObject, 'go_ItemContaniner', RewardContainer)
    --insertInitComp
    --insertOnClick
    --insertDeclareBtn
    end
end

--insertSetTxt

return _SimpleRewardPanelBase
