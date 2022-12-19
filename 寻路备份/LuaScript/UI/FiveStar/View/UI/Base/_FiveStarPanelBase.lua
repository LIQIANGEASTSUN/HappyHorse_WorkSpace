--insertRequire

---@class _FiveStarPanelBase:BasePanel
local _FiveStarPanelBase = class(BasePanel)

function _FiveStarPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.btn_close = nil
    self.onClick_btn_close = nil
end

function _FiveStarPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _FiveStarPanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        self.root = find_component(self.gameObject, "root")
        self.root1 = find_component(self.gameObject, "root1")
        self.btn_close = find_component(self.root, "btn_close")
        self.btn_close1 = find_component(self.root1, "btn_close")
        self.badButton = find_component(self.root, "badButton")
        self.goodButton = find_component(self.root, "goodButton")
        self.okButton = find_component(self.root1, "okButton")
        --insertInitComp
        --insertOnClick

        local function OnClick_btn_close(go)
            sendNotification(FiveStarPanelNotificationEnum.Click_btn_close)
            DcDelegates.Legacy:Log_web_user_eva_game(3, AppServices.FiveStarManager.data.showCount, self.arguments.scene_name)
        end
        --insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_close, OnClick_btn_close)
        Util.UGUI_AddButtonListener(self.btn_close1, OnClick_btn_close)
    end
end

--insertSetTxt

return _FiveStarPanelBase
