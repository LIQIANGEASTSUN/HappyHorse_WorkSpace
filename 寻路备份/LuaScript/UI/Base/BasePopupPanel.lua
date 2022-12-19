---即将弃用
BasePopupPanel = class(BasePanel)

-- function BasePopupPanel:ctor(_panelName)

--   self.name = _panelName or "BasePopupPanel"

--   self.arguments = nil

--   self.panelVO = nil
-- end

function BasePopupPanel:onBeforeBindView()

    local popupPanelMask = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_Common_PopupPanelMask)
    popupPanelMask.gameObject.name = "popupPanelMask"
    popupPanelMask.gameObject.transform.parent = self.gameObject.transform
    GameUtil.SetLocalPositionZero(popupPanelMask.gameObject)
    GameUtil.SetLocalScaleOne(popupPanelMask.gameObject)

    local sprite_popupPanelMask = popupPanelMask:GetComponent(UISprite)
    sprite_popupPanelMask.width = App.screenWidth;
    sprite_popupPanelMask.height = App.screenHeight;

end

function BasePopupPanel:fadeIn(_finishCallBack)

    GameUtil.SetLocalPosition(self.gameObject, 0, -75, 0)
    GameUtil.SetLocalPosition(self.popupPanelMask.gameObject, 0, 75, 0)
    self.gameObject:GetComponent(UIPanel).alpha = 0
    self.gameObject:SetActive(true)

    local popupPanelMaskTp = TweenPosition.Begin(self.popupPanelMask.gameObject, 0.2, Vector3.zero)
    local panelTa = TweenAlpha.Begin(self.gameObject, 0.2, 1)
    local panelTp = TweenPosition.Begin(self.gameObject, 0.2, Vector3.zero)

    local function finishTween(sender)

        self.gameObject:GetComponent(UIPanel).alpha = 1
        GameUtil.SetLocalPositionZero(self.popupPanelMask.gameObject)

        Object.Destroy(popupPanelMaskTp)
        Object.Destroy(panelTa)
        Object.Destroy(panelTp)

        if (_finishCallBack ~= nil) then
            _finishCallBack()
        end
    end

    panelTp:SetOnFinished(finishTween)
end

function BasePopupPanel:fadeOut(_finishCallBack)

    local popupPanelMaskTp = TweenPosition.Begin(self.popupPanelMask.gameObject, 0.2, Vector3(0, 75, 0))
    local panelTa = TweenAlpha.Begin(self.gameObject, 0.2, 0)
    local panelTp = TweenPosition.Begin(self.gameObject, 0.2, Vector3(0, -75, 0))

    local function finishTween(sender)
        self.gameObject:SetActive(false)

        GameUtil.SetLocalPositionZero(self.gameObject)
        self.gameObject:GetComponent(UIPanel).alpha = 1
        GameUtil.SetLocalPositionZero(self.popupPanelMask.gameObject)

        Object.Destroy(popupPanelMaskTp)
        Object.Destroy(panelTa)
        Object.Destroy(panelTp)

        if (_finishCallBack ~= nil) then
            _finishCallBack()
        end
    end

    panelTp:SetOnFinished(finishTween)

end

return BasePanel