--insertRequire

local _ModifyHeadImagePanelBase = class(BasePanel)

function _ModifyHeadImagePanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.btn_close = nil
    self.onClick_btn_close = nil
end

function _ModifyHeadImagePanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _ModifyHeadImagePanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        self.root = find_component(self.gameObject, "root")
        self.btn_close = self.root:FindGameObject("btn_close")
        self.tf_itemContent = find_component(self.root, "scr_heads/Viewport/Content")
        self.frame_scrollList = find_component(self.root, "src_frames", ScrollListRenderer)
        self.head_scrollList = find_component(self.root, "scr_heads", ScrollListRenderer)
        --text
        Runtime.Localize(self.root:FindGameObject("text_title"), "ui_settings_avatartitle")
        --insertInitComp
        self.toggles = {}
        for i = 1, 2 do
            local tog = find_component(self.root, "togGroup/" .. tostring(i), Toggle)
            local txt_name = find_component(tog.gameObject, "Text", Text)
            local img_reddot = find_component(tog.gameObject, "reddot", Image)
            txt_name.text = i == 1 and Runtime.Translate("ui_change_avatar") or Runtime.Translate("ui_change_frame")
            local key = i == 1 and "NewAvatar" or "AvatarFrame"
            local list = AppServices.User.Default:GetKeyValue(key, {})
            img_reddot:SetActive(not table.isEmpty(list))
            local function onValueChange(active)
                if active then
                    img_reddot:SetActive(false)
                    self:SwitchState(i)

                    --外部红点
                    local reddotName = i == 1 and "newHead" or "newFrame"
                    AppServices.User.Default:SetKeyValue(reddotName, 0,true)
                    AppServices.RedDotManage:ClearCount(reddotName)
                else
                    local k = i == 1 and "NewAvatar" or "AvatarFrame"
                    local t = AppServices.User.Default:GetKeyValue(k, {})
                    local isEmpty = table.isEmpty(t)
                    img_reddot:SetActive(not isEmpty)
                end
            end
            tog.onValueChanged:AddListener(onValueChange)
            self.toggles[i] = tog
        end

        self.go_avatar = self.root:FindGameObject("go_avatar")
        self.img_avatar = self.go_avatar:FindComponentInChildren("img_avatar", typeof(Image))
        self.img_avatarFrame = find_component(self.go_avatar, "img_avatarFrame", Image)
        self.txt_headName = find_component(self.go_avatar, "txt_name", Text)
        self.txt_avatarDesc = find_component(self.go_avatar, "txt_desc", Text)
        --insertOnClick

        self.onClick_btn_close = function()
            sendNotification(ModifyHeadImagePanelNotificationEnum.Click_btn_close)
        end

        local function OnClick_btn_close(go)
            if (self.onClick_btn_close ~= nil) then
                self.onClick_btn_close()
            end
        end
        --insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_close, OnClick_btn_close)
    end
end

--insertSetTxt

return _ModifyHeadImagePanelBase
