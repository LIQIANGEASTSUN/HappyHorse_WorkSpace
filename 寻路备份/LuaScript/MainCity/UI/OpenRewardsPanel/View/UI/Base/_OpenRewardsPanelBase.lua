--insertRequire
---@class _OpenRewardsPanelBase:BasePanel
local _OpenRewardsPanelBase = class(BasePanel)

function _OpenRewardsPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.img_buildingPh = nil
    self.go_continue = nil
    self.go_container = nil
    self.row1 = nil
    self.row2 = nil
    self.go_hitLayer = nil
    self.onClick_btn_hitLayer = nil
end

function _OpenRewardsPanelBase:setProxy(proxy)
    self.proxy = proxy
end

function _OpenRewardsPanelBase:bindView()
    if Runtime.CSValid(self.gameObject) then
        self.titleGo = self.gameObject:FindGameObject("go_title")

        local ray = self.gameObject:FindGameObject("go_placeholder/RayPanel/RayPanel_star")
        self.animator_ray = ray:GetComponent(typeof(Animator))

        local container = self.gameObject:FindGameObject("go_container")
        container.transform:SetAnchoredPosition(0, -130)
        container:SetLocalScale(Vector3.zero)
        self.go_container = container

        local row1 = self.gameObject:FindGameObject("go_container/Row1")
        self.row1 = row1:GetOrAddComponent(typeof(RewardContainer))
        self.row1:SetSpacing(0)

        local row2 = self.gameObject:FindGameObject("go_container/Row2")
        self.row2 = row2:GetOrAddComponent(typeof(RewardContainer))
        self.row2:SetSpacing(0)

        local imageGo = self.gameObject:FindGameObject("Image")
        local canvasGroup = imageGo:GetComponent(typeof(CanvasGroup))
        canvasGroup.alpha = 1
        local image = imageGo:GetComponent(typeof(Image))
        image.enabled = false

        self.go_continue = self.gameObject:FindGameObject("text_continue")
        self.go_starPaticles = self.gameObject:FindGameObject("go_placeholder/RayPanel/particles")
        --self.go_glow = row1:FindGameObject("RewardItem(clone)/img_glow")
        if self.arguments.duration and self.arguments.duration > 0 then
            self.go_continue:SetActive(false)
        else
            self.go_hitLayer = self.gameObject:FindGameObject("button")
            self:bindBtnCallback()
        end

        --text
        Runtime.Localize(self.go_continue, "ui_common_continue")
    end
end

function _OpenRewardsPanelBase:bindBtnCallback()
    self.onClick_btn_hitLayer = function()
        sendNotification(OpenRewardsPanelNotificationEnum.Click_btn_hitLayer)
    end

    local function OnClick_btn_hitLayer(go)
        if (self.onClick_btn_hitLayer ~= nil) then
            self.onClick_btn_hitLayer()
        end
    end

    Util.UGUI_AddButtonListener(self.go_hitLayer, OnClick_btn_hitLayer)
end

--insertSetTxt

return _OpenRewardsPanelBase
