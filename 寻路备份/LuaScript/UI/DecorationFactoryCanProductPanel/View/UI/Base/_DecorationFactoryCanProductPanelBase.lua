--insertRequire

---@class _DecorationFactoryCanProductPanelBase:BasePanel
local _DecorationFactoryCanProductPanelBase = class(BasePanel)

function _DecorationFactoryCanProductPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.go_scroll = nil
    self.btn_close = nil
    self.onClick_btn_close = nil
end

function _DecorationFactoryCanProductPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _DecorationFactoryCanProductPanelBase:bindView()
    if (self.gameObject ~= nil) then
		local go = self.gameObject
        --insertInit
        self.go_scroll = find_component(go, "go_scroll", ScrollListRenderer)
        self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))
		local txt_title = find_component(go, "txt_title", Text)
		txt_title.text = "可生产的建筑"
        --insertInitComp
        --insertOnClick
        local function OnClick_btn_close(go)
            sendNotification(DecorationFactoryCanProductPanelNotificationEnum.Click_btn_close)
        end
        --insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
    end
end

--insertSetTxt

return _DecorationFactoryCanProductPanelBase
