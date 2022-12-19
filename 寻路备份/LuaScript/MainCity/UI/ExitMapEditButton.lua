---@class ExitMapEditButton:LuaUiBase
local ExitMapEditButton = class(LuaUiBase,"ExitMapEditButton")

function ExitMapEditButton:Create()
    local inst = ExitMapEditButton.new()
    local go = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_EXIT_MAP_EDIT_BUTTON)
    inst:Init(go)
    return inst
end

function ExitMapEditButton:Init(gameObject)
    self:InitFromGameObject(gameObject)
    local onClick = function()
        self:OnBtnClick()
    end
    self.tf_btn = self.transform:Find("btn_exit")
    self.tf_top = self.transform:Find("topPart")
    self.tf_bottom = self.transform:Find("bottomPart")
    Util.UGUI_AddButtonListener(self.tf_btn.gameObject,onClick)
    self.originalAnchoredPosY = self.tf_btn.anchoredPosition.y
    self.topY = self.tf_top.anchoredPosition.y
    self.bottomY = self.tf_bottom.anchoredPosition.y
end

function ExitMapEditButton:ShowExitAnim(instant)
    DOTween.Kill(self.tf_btn, false)
    if instant then
        self.tf_btn.anchoredPosition = Vector2(self.tf_btn.anchoredPosition.x, self.originalAnchoredPosY)
    else
        GameUtil.DoAnchorPosY(self.tf_btn, self.originalAnchoredPosY, 0.5)
        GameUtil.DoAnchorPosY(self.tf_bottom, self.bottomY, 0.5)
    end
    self:HideTopPart()
end

function ExitMapEditButton:ShowEnterAnim(instant)
    DOTween.Kill(self.tf_btn, false)
    if instant then
        self.transform.anchoredPosition = Vector2(self.tf_btn.anchoredPosition.x, self.originalAnchoredPosY+150)
    else
        GameUtil.DoAnchorPosY(self.tf_btn, self.originalAnchoredPosY+200, 0.5)
        GameUtil.DoAnchorPosY(self.tf_bottom, self.bottomY+200, 0.5)

    end
    self:ShowTopPart()
end

function ExitMapEditButton:ShowTopPart()
    DOTween.Kill(self.tf_top,false)
    GameUtil.DoAnchorPosY(self.tf_top,self.topY - 80,0.5)
end

function ExitMapEditButton:HideTopPart()
    DOTween.Kill(self.tf_top,false)
    GameUtil.DoAnchorPosY(self.tf_top,self.topY,0.5)
end

function ExitMapEditButton:OnBtnClick()
    if self.buttonCallback and not PanelManager.isShowingAnyPanel() then
        self.buttonCallback()
    end
end

function ExitMapEditButton:SetButtonCallback(callback)
    self.buttonCallback = callback
end

function ExitMapEditButton:Dispose()
    LuaUiBase.Dispose(self)
    self.buttonCallback = nil
end

return ExitMapEditButton