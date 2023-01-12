--insertRequire

local _TownNamePanelBase = class(BasePanel)

function _TownNamePanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.text_title = nil
    self.btn_ok = nil
    self.onClick_btn_ok = nil
end

function _TownNamePanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _TownNamePanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        self.mask = find_component(self.gameObject, "mask")
        self.text_title = self.gameObject.transform:Find("text_title").gameObject:GetComponent(typeof(Text))
        self.btn_ok = self.gameObject.transform:Find("btn_ok").gameObject:GetComponent(typeof(Button))
        self.input_name = self.gameObject:FindComponentInChildren("input_name", typeof(CS.UnityEngine.UI.InputField))
        --insertInitComp

        self.onValueChanged_input_name = function(content)
            content = string.gsub(content, "%s+", "")
            if string.isEmpty(content) then
                self.btn_ok.Interactable = false
            else
                self.btn_ok.Interactable = true
            end
        end

        local function onValueChanged_input_name(content)
            if self.onValueChanged_input_name then
                self.onValueChanged_input_name(content)
            end
        end

        self.input_name.onValueChanged:AddListener(onValueChanged_input_name)
        --insertOnClick

        self.onClick_btn_ok = function()
            if self.btn_ok.Interactable then
                sendNotification(TownNamePanelNotificationEnum.Click_btn_ok)
            end
        end

        local function OnClick_btn_ok(go)
            if (self.onClick_btn_ok ~= nil) then
                self.onClick_btn_ok()
            end
        end
        --insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_ok.gameObject, OnClick_btn_ok)

        Util.UGUI_AddButtonListener(self.mask, function()
            sendNotification(TownNamePanelNotificationEnum.Close_Panel)
        end )
    end
end

function _TownNamePanelBase:BeforeHide()
end

--insertSetTxt

return _TownNamePanelBase
