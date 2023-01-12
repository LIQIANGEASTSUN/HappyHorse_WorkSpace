--insertRequire

---@class _OnHookBuildPanelBase:BasePanel
local _OnHookBuildPanelBase = class(BasePanel)

function _OnHookBuildPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.btn_close = nil
    self.onClick_btn_close = nil
    self.btn_sure = nil
    self.onClick_btn_sure = nil
    self.txt_title = nil
end

function _OnHookBuildPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _OnHookBuildPanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        self.contents = find_component(self.gameObject, "Contents")
        self.go_petIcon = find_component(self.gameObject, "go_petIcon", Image)
        self.txt_pet = find_component(self.gameObject, "txt_pet", Text)
        self.txt_outputCount = find_component(self.gameObject, "txt_outputCount", Text)
        self.txt_output = find_component(self.gameObject, "txt_output", Text)
        self.go_item = find_component(self.gameObject, "go_item", Image)
        self.txt_title = find_component(self.gameObject, "txt_title", Text)
        self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))
        self.btn_sure = self.gameObject.transform:Find("btn_sure").gameObject:GetComponent(typeof(Button))
        --insertInitComp
        --insertOnClick
        local function OnClick_btn_close(go)
            console.jf("OnClick_btn_close")
            sendNotification(OnHookBuildPanelNotificationEnum.Click_btn_close)
        end
        local function OnClick_btn_sure(go)
            console.jf("OnClick_btn_sure")
            sendNotification(OnHookBuildPanelNotificationEnum.Click_btn_sure)
        end
        --insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
        Util.UGUI_AddButtonListener(self.btn_sure.gameObject, OnClick_btn_sure)
    end
end

--insertSetTxt

return _OnHookBuildPanelBase
