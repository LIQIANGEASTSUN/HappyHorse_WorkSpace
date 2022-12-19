require "UI.Components.HomeSceneTopIconBase"
---@class InviteButton:HomeSceneTopIconBase
local InviteButton = class(HomeSceneTopIconBase, "InviteButton")

---@return InviteButton
function InviteButton:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_INVITE_BUTTON)
    return InviteButton:CreateWithGameObject(gameObject)
end

function InviteButton:CreateWithGameObject(gameObject)
    local instance = InviteButton.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function InviteButton:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.Interactable = true
    self.img_bg = find_component(gameObject, "img_bg", Image)
    Util.UGUI_AddButtonListener(
        self.gameObject,
        function()
            self:OnClick()
        end,
        {noAudio = true}
    )
end

function InviteButton:OnClick()
    --PanelManager.closeTopPanel()
    if not self.Interactable then
        return
    end
    if not App.globalFlags:CanClick() then
        return
    end
    App.globalFlags:SetClickFlag()
    -- -@type HRWidgetsMenu
    -- local widgetsMenu = App.scene:GetWidget(CONST.MAINUI.ICONS.HRWidgetsMenu)
    -- widgetsMenu:OnClickMenuBtn()
    PanelManager.showPanel(GlobalPanelEnum.InviteFriendsPanel)
end

function InviteButton:SetInteractable(value)
    self.Interactable = value
end

function InviteButton:SetParent(parent)
    self.gameObject.transform:SetParent(parent, false)
end

function InviteButton:NeedChangeParent(isOn)
    if AppServices.InviteFriends:IsWidgetOut() then
        self.img_bg:SetActive(not isOn)
        return isOn and 'in' or 'out'
    else
        self.img_bg:SetActive(false)
        return 'in'
    end
end

return InviteButton
