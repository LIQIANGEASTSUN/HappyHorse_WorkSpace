local BaseIconButton = require "UI.Components.BaseIconButton"
---@class LabButton:BaseIconButton
local LabButton = class(BaseIconButton)

function LabButton:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_LAB_BUTTON)
    return LabButton:CreateWithGameObject(gameObject)
end

function LabButton:CreateWithGameObject(gameObject)
    local instance = LabButton.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

local needShow = true
function LabButton:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.Interactable = true
    self.reddot = find_component(gameObject, "reddot")

    local function OnClick_button(go)
        if not self.Interactable then
            return
        end
        self:Hide()
        needShow = false
        local showCrown = AppServices.User:GetItemAmount(ItemId.CHIP) >= SceneServices.LabManager:GetCrownDrawCost()
        AppServices.Jump.FocusLab({crown = showCrown, gene = not showCrown})
    end
    Util.UGUI_AddButtonListener(self.gameObject, OnClick_button)

    MessageDispatcher:AddMessageListener(MessageType.Global_After_AddItem, self.OnAddItem, self)
end

function LabButton:Dispose()
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_AddItem, self.OnAddItem, self)
end

function LabButton:OnAddItem(itemId, deltaCount)
    local itemConfig = AppServices.Meta:GetItemMeta(itemId)
    if itemId == ItemId.CHIP then
        local chipCount = AppServices.User:GetItemAmount(ItemId.CHIP)
        local costCount = SceneServices.LabManager:GetCrownDrawCost()
        if chipCount >= costCount and (chipCount - deltaCount) < costCount then
            self:Show()
            needShow = true
        end
    elseif itemConfig.type == 30 then
        local hasCount = AppServices.User:GetItemAmount(itemId)
        local needCount = itemConfig.funcParam[2]
        if hasCount >= needCount and (hasCount - deltaCount) < needCount then
            self:Show()
            needShow = true
        end
    end
end

function LabButton:SetBtnCallback(callback)
    self.btnCallback = callback
end

function LabButton:CheckShowOrHide()
    local agent = SceneServices.LabManager:GetAgent()
    local showCrown = AppServices.User:GetItemAmount(ItemId.CHIP) >= SceneServices.LabManager:GetCrownDrawCost()
    if
        needShow and (showCrown or SceneServices.LabManager:HasCanCompose()) and App.scene:IsScene(SceneMode.home) and
            agent and
            agent:IsRenderValid()
     then
        self:Show()
        self.reddot:SetActive(true)
    else
        self:Hide()
    end
end

function LabButton:ShowForFly()
    self:Show()
    self.reddot:SetActive(false)
end

function LabButton:HideForFly()
    WaitExtension.SetTimeout(
        function()
            if Runtime.CSNull(self.gameObject) then
                return
            end
            self:Hide()
        end,
        0.3
    )
end

function LabButton:Show()
    if not App.scene:IsScene(SceneMode.home) then
        return
    end
    self.gameObject:SetActive(true)
end

function LabButton:Hide()
    self.gameObject:SetActive(false)
end

function LabButton:ShowExitAnim(exitImmediate, callback)
end

function LabButton:ShowEnterAnim(callback, showTime)
end

function LabButton:SetParent(parent)
    self.gameObject.transform:SetParent(parent, false)
    self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
end

function LabButton:SetInteractable(value)
    self.Interactable = value
end

return LabButton
