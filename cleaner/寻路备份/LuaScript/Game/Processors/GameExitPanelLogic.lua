
---@class GameExitPanelLogic
local GameExitPanelLogic = {}

function GameExitPanelLogic:Initialize()
    local go = BResource.InstantiateFromAssetName("Prefab/UI/Common/System/GameExitCanvas.prefab")
    self.go = go
    GameObject.DontDestroyOnLoad(self.go)

    self.mask = self.go:FindGameObject("GameExitPanel/Mask")

    self.lbTitle = find_component(go, "GameExitPanel/label_title", Text)
    self.lbContent = find_component(go, "GameExitPanel/label_content", Text)
    self.lbConfirm = find_component(go, "GameExitPanel/layout/btn_ok/Text", Text)
    self.lbCancel = find_component(go, "GameExitPanel/layout/btn_cancel/Text", Text)

    self.btnCancel = find_component(go, "GameExitPanel/layout/btn_cancel", Button)
    self.btnConfirm = find_component(go, "GameExitPanel/layout/btn_ok", Button)
    self.btnClose = find_component(go, "GameExitPanel/btn_close", Button)

    Util.UGUI_AddButtonListener(self.btnConfirm.gameObject, function()
        self:ShowPanel(false)
        App:Quit({source = "GameExitPanel"})
    end)
    Util.UGUI_AddButtonListener(self.btnCancel.gameObject, function()
        self:ShowPanel(false)
    end)
    Util.UGUI_AddButtonListener(self.btnClose.gameObject, function()
        self:ShowPanel(false)
    end)

    self.isVisible = false
    self.go:SetActive(self.isVisible)
end

function GameExitPanelLogic:ShowPanel(isVisible)
    if Runtime.CSNull(self.go) then
        return
    end

    if isVisible then
        self.lbTitle.text = Runtime.Translate("UI_SYSTEM_GAMEEXIT_TITLE")
        self.lbContent.text = Runtime.Translate("UI_SYSTEM_GAMEEXIT_CONTENT")
        self.lbConfirm.text = Runtime.Translate("ui_common_confirm")
        self.lbCancel.text = Runtime.Translate("ui_common_cancel")
    end

    self.isVisible = isVisible
    self.go:SetActive(isVisible)
end

function GameExitPanelLogic:ToggleState()
    self.isVisible = not self.isVisible
    self:ShowPanel(self.isVisible)
end

function GameExitPanelLogic:_close()
    -- console.print("GameExitPanelLogic --- _close") --@DEL
    --self.mask:SetActive(false)
    --self.spine:SetActive(false)
    --self.spineBg:SetActive(false)
    --self.restartBoard:SetActive(false)
    --self:_showPanel(false)
end

function GameExitPanelLogic:ClosePanel()
    self:_close()
end

function GameExitPanelLogic:DestroyPanel()
    self:stopTimers()
    Runtime.CSDestroy(self.go)
    self.go = nil
end

GameExitPanelLogic:Initialize()

return GameExitPanelLogic
